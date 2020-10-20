# frozen_string_literal: true

require "resque/tasks"

namespace :resque do
  task setup: :environment do
    Resque.before_fork = Proc.new do |job|
      ActiveRecord::Base.connection.disconnect!
    end
    Resque.after_fork = Proc.new do |job|
      ActiveRecord::Base.establish_connection
    end
  end

  # From https://gist.github.com/1870642
  desc "Restart running workers"
  task restart_workers: :environment do
    Rake::Task["resque:stop_workers"].invoke
    Rake::Task["resque:start_workers"].invoke
  end

  desc "Quit running workers"
  task stop_workers: :environment do
    stop_workers
  end

  desc "Start workers"
  task start_workers: :environment do
    run_worker("*", 1)
  end

  def store_pids(pids, mode)
    pids_to_store = pids
    pids_to_store += read_pids if mode == :append

    # Make sure the pid file is writable
    File.open(pid_file_path, "w") do |f|
      f << pids_to_store.join(",")
    end
  end

  def read_pids
    # pid_file_path = Rails.root.join('tmp', 'pids', 'resque.pid')
    return [] if !File.exists?(pid_file_path)

    File.open(pid_file_path, "r") do |f|
      f.read
    end.split(",").collect { |p| p.to_i }
  end

  def pid_file_path
    Rails.root.join("tmp", "pids", "resque.pid")
  end

  def stop_workers
    pids = read_pids

    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "$ #{syscmd}"
      `#{syscmd}`
      store_pids([], :write)
    end
  end

  # Start a worker with proper env vars and output redirection
  def run_worker(queue, count = 1)
    puts "Starting #{count} worker(s) with QUEUE: #{queue}"

    ## make sure log/resque_err, log/resque_stdout are writable
    ops = { pgroup: true,
            err: [Rails.root.join("log", "resque_err").to_s, "a"],
            out: [Rails.root.join("log", "resque_out").to_s, "a"] }
    env_vars = { "QUEUE" => queue.to_s, "RAILS_ENV" => Rails.env.to_s }

    pids = []
    count.times do
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
      pids << pid
    end

    store_pids(pids, :append)
  end

  # from https://gist.github.com/snikch/2371233
  # seems to hang capistrano/jenkins
  def run_worker_fork(queue, count = 1, ops = {})
    puts "Starting #{count} worker(s) with QUEUE: #{queue}"

    queues = queue.split(",")

    # get the git commit hash for later
    commit_hash = `cd #{Rails.root} && cat REVISION`[0, 12]

    pids = []
    child = false

    # Clear current db connection, ready to fork
    ::ActiveRecord::Base.clear_all_connections!
    count.times do
      pid = Process.fork
      if pid.nil? then
        # In child
        child = true

        # Keep alive after parent process detaches from the terminal
        Signal.trap("HUP", "IGNORE")

        # Restablish a db connection
        ::ActiveRecord::Base.establish_connection

        # Set up the new Resque worker
        worker = Resque::Worker.new(*queues)
        worker.verbose = false
        worker.very_verbose = false
        worker.log "Starting worker #{worker}"
        worker.work(5)

        # Add commit hash to worker name
        $0 = "resque-#{Resque::Version}: #{queues} (@#{commit_hash})"

        # Don't continue the loop in this child
        break
      else
        # In parent
        child = false

        # We don't care about the forked process
        Process.detach(pid)
        pids << pid
      end
    end

    # Only store if we're in the parent process
    store_pids(pids, :append) unless child
  end
end

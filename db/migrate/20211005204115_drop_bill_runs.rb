class DropBillRuns < ActiveRecord::Migration[6.1]
  def change
    # Note - We could have just gone with `drop_table :bill_runs`. The issue is if you then tried running
    # `rake db:rollback` it would fail. Providing it in this way means ActiveRecord understands how to recreate the
    # table on the down and avoid any problems
    # https://stackoverflow.com/a/31657066/6117745
    drop_table :bill_runs do |t|
      t.uuid    :bill_run_id
      t.string  :region
      t.string  :regime
      t.boolean :pre_sroc
      t.timestamps
    end
  end
end

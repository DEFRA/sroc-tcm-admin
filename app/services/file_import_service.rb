# frozen_string_literal: true

class FileImportService < ServiceObject
  def initialize(_params = {})
    super()
  end

  def call
    # Default the overall import result to `false`
    @result = false
    results = default_results
    return results unless SystemConfig.config.start_import

    begin
      # Look to see whether there are any files that need processing
      user = User.system_account
      Thread.current[:current_user] = user
      importer = TransactionFileImporter.new

      result = ListEtlImportFiles.call
      result.files.each do |f|
        begin
          puts("Importing file #{f}")
          in_file = Tempfile.new
          out_file = Tempfile.new
          GetEtlImportFile.call(remote_path: f, local_path: in_file.path)
          in_file.rewind

          transaction_file = importer.import(in_file.path, File.basename(f))
          in_file.rewind
          PutArchiveImportFile.call(local_path: in_file.path,
                                    remote_path: f)

          DeleteEtlImportFile.call(remote_path: f)
          results[:succeeded].push(f)

          begin
            processor = category_processor(transaction_file, user)
            puts("Category #{processor.class} #{processor}")
            processor&.suggest_categories
          rescue StandardError => e
            puts("Failed suggesting category for #{f}: #{e.message}")
          end
        rescue Exceptions::TransactionFileError, ArgumentError => e
          # invalid transaction file or some other file handling issue
          # move file to quarantine
          puts("Quarantining file #{f} because: #{e}")
          PutQuarantineFile.call(local_path: in_file.path,
                                 remote_path: f)
          DeleteEtlImportFile.call(remote_path: f)
          results[:quarantined].push(f)
        rescue StandardError => e
          puts("Failed to import file #{f}: #{e}")
          results[:failed].push(f)
        ensure
          in_file.close
          in_file.unlink
          out_file.close
          out_file.unlink
        end
      end

      # Set the service object result to `true` as long as nothing got quarantined or failed. Even if there are no files
      # imported the importer can be said to have completed 'successfully'. But we set the result to 'false' if any one
      # file fails
      @result = true unless (results[:quarantined].length + results[:failed].length).positive?

      log_result(results)

      results
    ensure
      SystemConfig.config.stop_import
    end
  end

  def category_processor(header, user)
    "Permits::#{header.regime.slug.capitalize}CategoryProcessor".constantize.new(header, user)
  end

  private

  def default_results
    {
      succeeded: [],
      quarantined: [],
      failed: []
    }
  end

  def log_result(results)
    message = "Successfully copied #{results[:succeeded].length} files, "\
      "failed to copy #{results[:failed].length}, "\
      "quarantined #{results[:quarantined].length} files"

    puts(message)
  end
end

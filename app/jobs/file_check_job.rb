class FileCheckJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Look to see whether there are any files that need processing
    service = FileStorageService.new
    importer = TransactionFileHandler.new

    files = service.list_files_in(:import)
    return unless files.count.positive?

    success = 0
    failed = 0
    quarantined = 0

    files.each do |f|
      begin
        in_file = Tempfile.new
        out_file = Tempfile.new
        service.fetch_file_from(:import, f, in_file.path)
        in_file.rewind

        transaction = importer.import(in_file.path)
        if transaction && transaction.valid?
          in_file.rewind
          service.store_file_in(:import_archive, in_file.path, f)
          # importer.export(transaction, out_file.path)
          # out_file.rewind
          # service.store_file_in(:export, out_file.path, f)
          service.delete_file_from(:import, f)
          success += 1
        else
          raise Exceptions::TransactionFileError, "File generated invalid transaction record [#{f}]"
        end
      rescue Exceptions::TransactionFileError => e
        # invalid transaction file or some other file handling issue
        quarantine(service, in_file, f)
        quarantined += 1
      rescue => e
        Rails.logger.warn("Failed to copy file: #{e}")
        failed += 1
      ensure
        in_file.close
        in_file.unlink
        out_file.close
        out_file.unlink
      end
    end

    Rails.logger.info("Successfully copied #{success} files, failed to copy #{failed}, quarantined #{quarantined} files")
  end

  def quarantine(service, tmp_file, filename)
    # move a dodgy or error file out of the import folder and stash smoewhere else
    service.store_file_in(:quarantine, tmp_file.path, filename)
    service.delete_file_from(:import, filename)
  rescue => e
    Rails.logger.warn "Error quarantining file [#{filename}]: #{e}"
  end
end

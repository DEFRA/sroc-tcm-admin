# frozen_string_literal: true

namespace :jobs do
  desc "Check for and process transaction import files"
  task file_import: :environment do
    FileImportService.call
  end

  desc "Generate a compressed data export file for each regime"
  task data_export: :environment do
    DataExportService.call
  end

  desc "Export queued transaction files"
  task file_export: :environment do
    TransactionFileExportService.call
  end
end

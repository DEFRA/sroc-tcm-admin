# frozen_string_literal: true

class PutArchiveExportFile < ServiceObject
  include FileStorage

  def initialize(params = {})
    super()
    @local_path = params.fetch(:local_path)
    @remote_path = params.fetch(:remote_path)
  end

  def call
    # store file in archive bucket
    archive_file_store.store_file(@local_path, export_path)
    @result = true
    self
  end

  private

  def export_path
    File.join("export", @remote_path)
  end
end

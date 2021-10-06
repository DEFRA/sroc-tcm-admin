# frozen_string_literal: true

module FileStorage
  def etl_file_store
    EtlFileStore.new
  end

  def archive_file_store
    ArchiveFileStore.new
  end
end

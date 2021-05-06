# frozen_string_literal: true

require "rails_helper"

RSpec.describe PutDataExportFileService do
  let(:cache_path) { Rails.root.join("tmp", "cache", "export_data") }
  let(:archive_path) { Rails.root.join(LocalFileStore.new("archive_bucket").base_path, "csv") }
  let(:service) { PutDataExportFileService }

  after(:each) do
    # Clean up - ensure any files we create irrespective of whether the test is successful or not are deleted
    Helpers::FileHelpers.clean_up(filename, cache_path)
    Helpers::FileHelpers.clean_up(filename, archive_path)
  end

  describe "#call" do
    context "when the file does not exist" do
      let(:filename) { "foo.csv" }

      it "marks the export as failed" do
        result = service.call(filename: File.join(cache_path, filename))

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

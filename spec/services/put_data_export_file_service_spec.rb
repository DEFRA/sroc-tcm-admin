# frozen_string_literal: true

require "rails_helper"

RSpec.describe PutDataExportFileService do
  let(:archive_path) { Rails.root.join(LocalFileStore.new("archive_bucket").base_path, "csv") }
  let(:fixture_path) { Rails.root.join("spec", "fixtures", "export_files") }
  let(:service) { PutDataExportFileService }

  after(:each) do
    # Clean up - ensure any files we create irrespective of whether the test is successful or not are deleted
    Helpers::FileHelpers.clean_up(export_file, archive_path)
  end

  describe "#call" do
    context "when the file exists" do
      let(:export_file) { "cfd_transactions.csv" }

      it "copys the file to the archive csv folder" do
        service.call(filename: File.join(fixture_path, export_file))

        # We check both the source and the destination folders to confirm the file was just copied, and not copied then
        # deleted
        expect(File.exist?(File.join(archive_path, export_file))).to be(true)
        expect(File.exist?(File.join(fixture_path, export_file))).to be(true)
      end

      it "marks the export as failed" do
        result = service.call(filename: File.join(fixture_path, export_file))

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when the file does not exist" do
      let(:export_file) { "foo.csv" }

      it "marks the export as failed" do
        result = service.call(filename: File.join(fixture_path, export_file))

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end

    context "when an error is thrown" do
      let(:export_file) { "cfd_transactions.csv" }

      before(:each) do
        allow_any_instance_of(FileStorage).to receive(:archive_file_store).and_raise("boom")
      end

      it "marks the export as failed" do
        result = service.call(filename: File.join(fixture_path, export_file))

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

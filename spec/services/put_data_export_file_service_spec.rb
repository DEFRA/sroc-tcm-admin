# frozen_string_literal: true

require "rails_helper"

RSpec.describe PutDataExportFileService do
  let(:service) { PutDataExportFileService }
  let(:test_export_full_file_name) { Helpers::FileHelpers.fixture_path(export_file_name, "export_files") }
  let(:s3_archives_regex) { Helpers::S3Helpers.archives_regex("csv", export_file_name) }

  describe "#call" do
    let(:s3_status) { 200 }

    before(:each) do
      stub_request(:put, s3_archives_regex).to_return(status: s3_status)
    end

    context "when the file exists" do
      let(:export_file_name) { "cfd_transactions.csv" }

      it "copys the file to the archive csv folder" do
        service.call(filename: test_export_full_file_name)

        # Confirm a request is made to upload the file to the S3 archive bucket as well
        expect(WebMock).to have_requested(:put, s3_archives_regex).once
      end

      it "marks the export as succeeded" do
        result = service.call(filename: test_export_full_file_name)

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when the file does not exist" do
      let(:export_file_name) { "foo.csv" }

      it "marks the export as failed" do
        result = service.call(filename: test_export_full_file_name)

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end

    context "when an error is thrown" do
      let(:export_file_name) { "cfd_transactions.csv" }
      let(:s3_status) { 403 }

      it "marks the export as failed" do
        result = service.call(filename: test_export_full_file_name)

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

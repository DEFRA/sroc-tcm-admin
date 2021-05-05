# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExportTransactionDataService do
  let(:cache_path) { Rails.root.join("tmp", "cache", "export_data") }
  let(:service) { ExportTransactionDataService }
  let!(:regime) { create(:regime) }

  after(:each) do
    # Clean up - ensure any files we create irrespective of whether the test is successful or not are deleted
    Helpers::FileHelpers.clean_up(regime.export_data_file.filename, cache_path)
    Helpers::FileHelpers.clean_up(regime.export_data_file.exported_filename, cache_path)
  end

  describe "#new" do
    let!(:regime) { create(:regime) }

    it "defaults 'batch_size' to 1000" do
      new_instance = service.new(regime: regime)

      expect(new_instance.batch_size).to eq(1000)
    end
  end

  describe "#call" do
    it "sets the status of the regime's 'ExportDataFile' to generating" do
      allow(regime.export_data_file).to receive(:generating!)

      service.call(regime: regime)

      expect(regime.export_data_file).to have_received(:generating!)
    end

    context "when there is no data to export" do
      it "still creates an export file" do
        result = service.call(regime: regime)

        expect(File.exist?(result.filename)).to be(true)
      end

      it "still updates the 'ExportDataFile's export related fields" do
        before_timestamp = DateTime.now
        result = service.call(regime: regime)
        sha1 = Digest::SHA1.file(result.filename).hexdigest

        expect(regime.export_data_file.last_exported_at).to be > before_timestamp
        expect(regime.export_data_file.exported_filename).to eq(File.basename(result.filename))
        expect(regime.export_data_file.exported_filename_hash).to eq(sha1)
      end

      it "sets the status of the regime's 'ExportDataFile' to success" do
        service.call(regime: regime)

        expect(regime.export_data_file.status).to eq("success")
      end

      it "marks the export as successful" do
        result = service.call(regime: regime)

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end
  end
end

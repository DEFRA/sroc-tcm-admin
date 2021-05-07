# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataExportService do
  describe "#call" do
    let(:service) { DataExportService }

    before(:each) do
      # The service uses `puts()` to ensure details are logged when run from a rake task. We don't want that
      # output in our tests so we use this to silence it. If you need to debug anything whilst working on tests
      # for it just comment out this line temporarily
      allow($stdout).to receive(:puts)
    end

    context "when exporting the transactions succeeds" do
      let!(:regime) { create(:regime) }

      before(:each) do
        exportDouble = double("ExportTransactionDataService", :failed? => false, :filename => "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { exportDouble }

        putFileDouble = double("PutDataExportFileService", :failed? => false)
        allow(PutDataExportFileService).to receive(:call) { putFileDouble }
      end

      it "marks the export as successful" do
        result = service.call()

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when exporting the transactions fails" do
      let!(:regime) { create(:regime) }

      before(:each) do
        exportDouble = double("ExportTransactionDataService", :failed? => true)
        allow(ExportTransactionDataService).to receive(:call) { exportDouble }
      end

      it "still marks the export as successful" do
        # If exporting the transactions fails then PutDataExportFileServiceshould never be called
        expect(PutDataExportFileService).to_not receive(:call)

        result = service.call()

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when 'putting' the file fails" do
      let!(:regime) { create(:regime) }

      before(:each) do
        exportDouble = double("ExportTransactionDataService", :failed? => false, :filename => "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { exportDouble }

        putFileDouble = double("PutDataExportFileService", :failed? => true)
        allow(PutDataExportFileService).to receive(:call) { putFileDouble }
      end

      it "still marks the export as successful" do
        result = service.call()

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when an error is thrown" do
      let!(:regime) { create(:regime) }

      before(:each) do
        allow(ExportTransactionDataService).to receive(:call).and_raise("boom")
      end

      it "marks the export as failed" do
        result = service.call()

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

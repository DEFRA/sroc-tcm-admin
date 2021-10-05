# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataExportService do
  describe "#call" do
    let!(:regime) { create(:regime) }
    let(:service) { DataExportService }

    before(:each) do
      # The service uses `puts()` to ensure details are logged when run from a rake task. We don't want that
      # output in our tests so we use this to silence it. If you need to debug anything whilst working on tests
      # for it just comment out this line temporarily
      allow($stdout).to receive(:puts)
    end

    context "when no regime is specified" do
      before(:each) do
        # Create the additional regimes
        create(:regime, :pas)
        create(:regime, :wml)

        export_double = double("ExportTransactionDataService", failed?: false, filename: "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { export_double }

        put_file_double = double("PutDataExportFileService", failed?: false)
        allow(PutDataExportFileService).to receive(:call) { put_file_double }
      end

      it "runs the export 3 times, one for each regime" do
        result = service.call

        expect(ExportTransactionDataService).to have_received(:call).exactly(3).times
        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when a regime is specified" do
      before(:each) do
        export_double = double("ExportTransactionDataService", failed?: false, filename: "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { export_double }

        put_file_double = double("PutDataExportFileService", failed?: false)
        allow(PutDataExportFileService).to receive(:call) { put_file_double }
      end

      it "runs the export 3 times, one for each regime" do
        result = service.call(regime: regime)

        expect(ExportTransactionDataService).to have_received(:call).exactly(1).times
        expect(ExportTransactionDataService).to have_received(:call).with({ regime: regime })
        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when exporting the transactions succeeds" do
      before(:each) do
        export_double = double("ExportTransactionDataService", failed?: false, filename: "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { export_double }

        put_file_double = double("PutDataExportFileService", failed?: false)
        allow(PutDataExportFileService).to receive(:call) { put_file_double }
      end

      it "marks the export as successful" do
        result = service.call

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when exporting the transactions fails" do
      before(:each) do
        export_double = double("ExportTransactionDataService", failed?: true)
        allow(ExportTransactionDataService).to receive(:call) { export_double }
      end

      it "still marks the export as successful" do
        # If exporting the transactions fails then PutDataExportFileServiceshould never be called
        expect(PutDataExportFileService).to_not receive(:call)

        result = service.call

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when 'putting' the file fails" do
      before(:each) do
        export_double = double("ExportTransactionDataService", failed?: false, filename: "cfd_transactions.csv.gz")
        allow(ExportTransactionDataService).to receive(:call) { export_double }

        put_file_double = double("PutDataExportFileService", failed?: true)
        allow(PutDataExportFileService).to receive(:call) { put_file_double }
      end

      it "still marks the export as successful" do
        result = service.call

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end
    end

    context "when an error is thrown" do
      before(:each) do
        allow(ExportTransactionDataService).to receive(:call).and_raise("boom")
      end

      it "marks the export as failed" do
        result = service.call

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

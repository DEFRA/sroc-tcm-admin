# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataExportService do
  describe "#call", focus: false do
    let(:service) { DataExportService }

    context "when an error is thrown" do
      let!(:regime) { create(:regime) }
      before(:each) do
        allow(ExportTransactionDataService).to receive(:call).and_raise("boom")
      end

      it "marks the export as failed" do
        result = service.call()
        puts("Result #{result}")

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe CleanDbService do
  describe "#call" do
    context "when no error is thrown" do
      let(:connection) do
        double(
          "connection",
          tables: %w[schema_migrations table_1 table_2],
          execute: true
        )
      end

      before(:each) do
        allow(ActiveRecord::Base).to receive(:connection) { connection }
      end

      it "marks the clean as successful" do
        result = described_class.call

        expect(result.success?).to be(true)
        expect(result.failed?).to be(false)
      end

      it "only cleans certain tables" do
        result = described_class.call

        expect(result.results[:succeeded]).to eq(%w[table_1 table_2])
      end
    end

    context "when an error is thrown" do
      before(:each) do
        allow(ActiveRecord::Base).to receive(:connection).and_raise("boom")
      end

      it "marks the clean as failed" do
        result = described_class.call

        expect(result.success?).to be(false)
        expect(result.failed?).to be(true)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionCsvPresenter do
  let(:subject) { TransactionCsvPresenter.new(transaction_header) }
  let(:regime) { create(:regime) }

  describe "#header" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      create(:transaction_detail, transaction_header: transaction_header)
    end

    it "returns the correct value" do
      expect(subject.header).to eq(["H", "0000000", "CFD", "A", "I", 371, nil, "13-AUG-2021"])
    end
  end

  describe "#details" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header),
        create(:transaction_detail, transaction_header: transaction_header),
        create(:transaction_detail, transaction_header: transaction_header)
      ]
    end

    it "returns an array based on the linked transaction_details" do
      result = subject.details

      expect(result.length).to eq(3)
      expect(result[0][5]).to eq(transaction_details[0].transaction_reference)
      expect(result[1][5]).to eq(transaction_details[1].transaction_reference)
      expect(result[2][5]).to eq(transaction_details[2].transaction_reference)
    end
  end

  describe "#trailer" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      create(:transaction_detail, transaction_header: transaction_header)
    end

    it "returns the correct value" do
      expect(subject.trailer).to eq(["T", "0000002", 3, 0, 0])
    end
  end
end

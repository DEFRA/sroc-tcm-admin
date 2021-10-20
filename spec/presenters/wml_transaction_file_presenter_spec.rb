# frozen_string_literal: true

require "rails_helper"

RSpec.describe WmlTransactionFilePresenter do
  let(:subject) { WmlTransactionFilePresenter.new(transaction_file) }
  let(:regime) { create(:regime, :wml) }
  let(:user) { create(:user_with_regime, regime: regime) }
  let(:transaction_header) { create(:transaction_header, :wml, regime: regime) }
  let(:transaction_details) do
    [
      create(:transaction_detail, :wml, transaction_header: transaction_header, line_amount: line_amount)
    ]
  end
  let(:transaction_file) do
    create(:transaction_file, regime: regime, user: user, transaction_details: transaction_details)
  end
  let(:expected_credit_result) do
    [
      "D",
      "0000000",
      "A1234B",
      "29-SEP-2021",
      nil,
      nil,
      "",
      "GBP",
      "",
      "29-SEP-2021",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "23747",
      "",
      "3",
      "Credit of subsistence charge for permit category 2.15.2 due to the licence being surrendered.wef 6/3/2018 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, EPR Ref: XZ3333PG/A001",
      "JT",
      "",
      "",
      "026101",
      "From 6th March 2018 (26 Days)",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "Each",
      "23747"
    ]
  end
  let(:expected_debit_result) do
    [
      "D",
      "0000000",
      "A1234B",
      "29-SEP-2021",
      nil,
      nil,
      "",
      "GBP",
      "",
      "29-SEP-2021",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "23747",
      "",
      "3",
      "Site: Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, EPR Ref: XZ3333PG/A001",
      "JT",
      "",
      "From 6th March 2018 (26 Days)",
      "01/04/17 - 10/08/17",
      "2.15.2",
      "132/365",
      nil,
      nil,
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "1",
      "Each",
      "23747"
    ]
  end

  before(:each) do
    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#detail_row" do
    let(:line_amount) { 1 }

    context "if the transaction_detail is a credit" do
      let(:line_amount) { -1 }

      it "returns an array of values based on the provided presenter" do
        presenter = WmlTransactionDetailPresenter.new(transaction_file.transaction_details.first)

        expect(subject.detail_row(presenter, 0)).to eq(expected_credit_result)
      end
    end

    context "if the transaction_detail is a debit" do
      it "returns an array of values based on the provided presenter" do
        presenter = WmlTransactionDetailPresenter.new(transaction_file.transaction_details.first)

        expect(subject.detail_row(presenter, 0)).to eq(expected_debit_result)
      end
    end

    it "pads the index provided with seven 0's" do
      presenter = WmlTransactionDetailPresenter.new(transaction_file.transaction_details.first)

      expect(subject.detail_row(presenter, 1)[1]).to eq("0000001")
    end
  end

  describe "#credit_detail_row" do
    let(:line_amount) { -1 }

    it "returns an array of values based on the provided presenter" do
      presenter = WmlTransactionDetailPresenter.new(transaction_file.transaction_details.first)

      expect(subject.credit_detail_row(presenter, 0)).to eq(expected_credit_result)
    end
  end

  describe "#invoice_detail_row" do
    let(:line_amount) { 1 }

    it "returns an array of values based on the provided presenter" do
      presenter = WmlTransactionDetailPresenter.new(transaction_file.transaction_details.first)

      expect(subject.invoice_detail_row(presenter, 0)).to eq(expected_debit_result)
    end
  end
end

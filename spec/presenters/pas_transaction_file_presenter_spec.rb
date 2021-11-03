# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasTransactionFilePresenter do
  let(:subject) { PasTransactionFilePresenter.new(transaction_file) }
  let(:regime) { create(:regime, :pas) }
  let(:user) { create(:user_with_regime, regime: regime) }
  let(:transaction_header) { create(:transaction_header, :pas, regime: regime) }
  let(:transaction_details) do
    [
      create(:transaction_detail, :pas, transaction_header: transaction_header)
    ]
  end
  let(:transaction_file) do
    create(:transaction_file, regime: regime, user: user, transaction_details: transaction_details)
  end

  before(:each) do
    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#detail_row" do
    it "returns an array of values based on the provided presenter" do
      presenter = PasTransactionDetailPresenter.new(transaction_file.transaction_details.first)

      expect(subject.detail_row(presenter, 0)).to eq(
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
          "Site: Red St. Hill Farm, , , , ,AB12 1AB",
          "PT",
          "D",
          "VP3839DA",
          "01/04/17 - 10/08/17",
          nil,
          "132/365",
          nil,
          nil,
          "F",
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
      )
    end

    it "pads the index provided with seven 0's" do
      presenter = PasTransactionDetailPresenter.new(transaction_file.transaction_details.first)

      expect(subject.detail_row(presenter, 1)[1]).to eq("0000001")
    end
  end
end

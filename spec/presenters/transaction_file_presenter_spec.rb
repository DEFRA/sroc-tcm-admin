# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionFilePresenter do
  let(:subject) { TransactionFilePresenter.new(transaction_file) }
  let(:regime) { create(:regime) }
  let(:user) { create(:user_with_regime, regime: regime) }

  before(:each) do
    # This is a common call in a number of places in the code required for the auditing solution implemented. It expects
    # the current user to be set so it can capture who performed the action. In this case when a new transaction file
    # is created who created it is audited
    Thread.current[:current_user] = user
  end

  describe "#detail_row" do
    let(:transaction_file) { build(:transaction_file, regime: regime, user: user) }

    it "raises an error as it expects method to be implemented in the subclass" do
      expect { subject.detail_row(nil, nil) }.to raise_error("Implement me in a subclass")
    end
  end

  describe "#details" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header),
        create(:transaction_detail, transaction_header: transaction_header)
      ]
    end
    let(:transaction_file) do
      create(:transaction_file, regime: regime, user: user, transaction_details: transaction_details)
    end

    it "raises an error because it calls #detail_row() which needs to be implemented in the subclass" do
      expect { subject.details }.to raise_error("Implement me in a subclass")
    end
  end

  describe "#header" do
    let(:transaction_file) { build(:transaction_file, regime: regime, user: user) }

    it "returns the correct value" do
      expect(subject.header).to eq(["H", "0000000", "CFD", "A", "I", nil, "", "29-SEP-2021"])
    end
  end

  describe "#trailer" do
    let(:transaction_file) { build(:transaction_file, regime: regime, user: user) }

    it "returns the correct value" do
      expect(subject.trailer).to eq(["T", "0000001", "0000002", 0, 0])
    end
  end
end

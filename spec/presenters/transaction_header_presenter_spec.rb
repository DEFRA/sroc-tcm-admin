# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionHeaderPresenter do
  let(:subject) { TransactionHeaderPresenter.new(transaction_header) }
  let(:regime) { create(:regime) }

  describe "#billed_items" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header, status: "unbilled"),
        create(:transaction_detail, transaction_header: transaction_header, status: "billed"),
        create(:transaction_detail, transaction_header: transaction_header, status: "retro_billed")
      ]
    end

    it "returns the correct value" do
      result = subject.billed_items

      expect(result.length).to eq(2)
      expect(result).to eq(transaction_details[1..2])
    end
  end

  describe "can_be_removed?" do
    context "when the transaction header is not removed and has no billed or excluded items" do
      let(:transaction_header) { create(:transaction_header, regime: regime) }
      let!(:transaction_details) do
        create(:transaction_detail, transaction_header: transaction_header, status: "unbilled")
      end

      it "returns 'true'" do
        expect(subject.can_be_removed?).to eq(true)
      end
    end

    context "when the transaction header is removed" do
      let(:transaction_header) { create(:transaction_header, :removed, regime: regime) }
      let!(:transaction_details) do
        create(:transaction_detail, transaction_header: transaction_header, status: "unbilled")
      end

      it "returns 'false'" do
        expect(subject.can_be_removed?).to eq(false)
      end
    end

    context "when the transaction header has billed items" do
      let(:transaction_header) { create(:transaction_header, regime: regime) }
      let!(:transaction_details) do
        create(:transaction_detail, transaction_header: transaction_header, status: "billed")
      end

      it "returns 'false'" do
        expect(subject.can_be_removed?).to eq(false)
      end
    end

    context "when the transaction header has excluded items" do
      let(:transaction_header) { create(:transaction_header, regime: regime) }
      let!(:transaction_details) do
        create(:transaction_detail, transaction_header: transaction_header, status: "excluded")
      end

      it "returns 'false'" do
        expect(subject.can_be_removed?).to eq(false)
      end
    end
  end

  describe "#created_at" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }

    it "returns the correct value" do
      expect(subject.created_at).to eq(Date.today.strftime("%d/%m/%y"))
    end
  end

  describe "#excluded_items" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header, status: "billed"),
        create(:transaction_detail, transaction_header: transaction_header, status: "excluded"),
        create(:transaction_detail, transaction_header: transaction_header, status: "excluded")
      ]
    end

    it "returns the correct value" do
      result = subject.excluded_items

      expect(result.length).to eq(2)
      expect(result).to eq(transaction_details[1..2])
    end
  end

  describe "#generated_at" do
    let(:transaction_header) { build(:transaction_header, regime: regime) }

    it "returns the correct value" do
      expect(subject.generated_at).to eq("13/08/21")
    end
  end

  describe "#removed_by" do
    let(:user) { build(:user_with_regime, regime: regime) }
    let(:transaction_header) { build(:transaction_header, :removed, regime: regime, removed_by: user) }

    it "returns the correct value" do
      expect(subject.removed_by).to eq("System Account")
    end
  end

  describe "#removed_at" do
    let(:user) { build(:user_with_regime, regime: regime) }
    let(:transaction_header) { build(:transaction_header, :removed, regime: regime) }

    it "returns the correct value" do
      expect(subject.removed_at).to eq("13/08/21 00:00:00")
    end
  end

  describe "#transactions" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header),
        create(:transaction_detail, transaction_header: transaction_header)
      ]
    end

    it "returns the correct value" do
      result = subject.transactions

      expect(result.length).to eq(2)
      expect(result[0]).to eq(transaction_details[0])
    end
  end

  describe "#unbilled_items" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(:transaction_detail, transaction_header: transaction_header, status: "billed"),
        create(:transaction_detail, transaction_header: transaction_header, status: "unbilled"),
        create(:transaction_detail, transaction_header: transaction_header, status: "retrospective")
      ]
    end

    it "returns the correct value" do
      result = subject.unbilled_items

      expect(result.length).to eq(2)
      expect(result).to eq(transaction_details[1..2])
    end
  end

  describe ".wrap" do
    let(:transaction_headers) do
      [
        build(:transaction_header, regime: regime, removal_reference: "ABCDE12345"),
        build(:transaction_header, regime: regime)
      ]
    end

    it "returns a collection containing a TransactionHeaderPresenter for each TransactionHeader" do
      result = TransactionHeaderPresenter.wrap(transaction_headers)

      expect(result.length).to eq(2)
      expect(result[0]).to be_a(TransactionHeaderPresenter)
      expect(result[0].removal_reference).to eq(transaction_headers[0].removal_reference)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionDetailPresenter do
  let(:subject) { TransactionDetailPresenter.new(transaction_detail) }
  let(:regime) { build(:regime) }
  let(:transaction_header) { build(:transaction_header, regime: regime) }

  describe "#billable_days" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.billable_days).to eq(132)
    end

    it "matches the second part of the transaction's line_attr_4" do
      billable_days_part = transaction_detail.line_attr_4.split("/")[1].to_i

      expect(subject.billable_days).to eq(billable_days_part)
    end
  end

  describe "#charge_period" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.charge_period).to eq("FY2021")
    end
  end

  describe "#financial_year" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.financial_year).to eq(2017)
    end
  end

  describe "#financial_year_days" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.financial_year_days).to eq(365)
    end

    it "matches the first part of the transaction's line_attr_4" do
      financial_year_days_part = transaction_detail.line_attr_4.split("/")[0].to_i

      expect(subject.financial_year_days).to eq(financial_year_days_part)
    end
  end

  describe "#pre_sroc_flag" do
    context "when status is 'retrospective'" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, status: "retrospective")
      end

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("Y")
      end
    end

    context "when status is 'retro_billed'" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, status: "retro_billed")
      end

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("Y")
      end
    end

    context "when status is not 'retrospective' or 'retro_billed'" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header)
      end

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("N")
      end
    end
  end

  describe "#pro_rata_days" do
    context "when billable days equals financial year days" do
      let(:transaction_detail) do
        build(
          :transaction_detail,
          period_start: "01-Apr-2017",
          period_end: "31-Mar-2018",
          transaction_header: transaction_header
        )
      end

      it "returns the correct value" do
        expect(subject.pro_rata_days).to eq("")
      end
    end

    context "when billable days does not equal financial year days" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

      it "returns the correct value" do
        expect(subject.pro_rata_days).to eq("132/365")
      end
    end
  end

  describe "#temporary_cessation_file" do
    context "when temporary_cessation is true" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: true)
      end

      it "returns the correct value" do
        expect(subject.temporary_cessation_file).to eq("50%")
      end
    end

    context "when temporary_cessation is false" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: false)
      end

      it "returns the correct value" do
        expect(subject.temporary_cessation_file).to eq("")
      end
    end
  end

  describe "#temporary_cessation_flag" do
    context "when temporary_cessation is true" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: true)
      end

      it "returns the correct value" do
        expect(subject.temporary_cessation_flag).to eq("Y")
      end
    end

    context "when temporary_cessation is false" do
      let(:transaction_detail) do
        build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: false)
      end

      it "returns the correct value" do
        expect(subject.temporary_cessation_flag).to eq("N")
      end
    end
  end
end

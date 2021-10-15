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
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header, status: status) }

    context "when status is 'retrospective'" do
      let(:status) { "retrospective" }

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("Y")
      end
    end

    context "when status is 'retro_billed'" do
      let(:status) { "retro_billed" }

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("Y")
      end
    end

    context "when status is not 'retrospective' or 'retro_billed'" do
      let(:status) { "unbilled" }

      it "returns the correct value" do
        expect(subject.pre_sroc_flag).to eq("N")
      end
    end
  end

  describe "#pro_rata_days" do
    let(:transaction_detail) do
      build(
        :transaction_detail,
        transaction_header: transaction_header,
        period_start: period_start,
        period_end: period_end
      )
    end

    context "when billable days equals financial year days" do
      let(:period_start) { "01-Apr-2017" }
      let(:period_end) { "31-Mar-2018" }

      it "returns the correct value" do
        expect(subject.pro_rata_days).to eq("")
      end
    end

    context "when billable days does not equal financial year days" do
      let(:period_start) { "01-Apr-2017" }
      let(:period_end) { "10-Aug-2017" }

      it "returns the correct value" do
        expect(subject.pro_rata_days).to eq("132/365")
      end
    end
  end

  describe "#tcm_compliance_percentage" do
    test_data = [
      { example: "blank", band: "", expected: "" },
      { example: "'()'", band: "()", expected: "" },
      { example: "'A'", band: "A", expected: "" },
      { example: "'A (110%)'", band: "A (110%)", expected: "110%" }
    ]

    test_data.each do |data|
      context "when 'compliancePerformanceBand' in the charge_calculation is #{data[:example]}" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            transaction_header: transaction_header,
            charge_calculation: {
              "calculation": {
                "compliancePerformanceBand": data[:band]
              }
            }
          )
        end

        it "returns the correct value" do
          expect(subject.tcm_compliance_percentage).to eq(data[:expected])
        end
      end
    end
  end

  describe "#temporary_cessation_file" do
    let(:transaction_detail) do
      build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: temporary_cessation)
    end

    context "when temporary_cessation is true" do
      let(:temporary_cessation) { true }

      it "returns the correct value" do
        expect(subject.temporary_cessation_file).to eq("50%")
      end
    end

    context "when temporary_cessation is false" do
      let(:temporary_cessation) { false }

      it "returns the correct value" do
        expect(subject.temporary_cessation_file).to eq("")
      end
    end
  end

  describe "#temporary_cessation_flag" do
    let(:transaction_detail) do
      build(:transaction_detail, transaction_header: transaction_header, temporary_cessation: temporary_cessation)
    end

    context "when temporary_cessation is true" do
      let(:temporary_cessation) { true }

      it "returns the correct value" do
        expect(subject.temporary_cessation_flag).to eq("Y")
      end
    end

    context "when temporary_cessation is false" do
      let(:temporary_cessation) { false }

      it "returns the correct value" do
        expect(subject.temporary_cessation_flag).to eq("N")
      end
    end
  end

  describe "#transaction_date" do
    let(:transaction_detail) do
      build(
        :transaction_detail,
        transaction_header: transaction_header,
        charge_calculation: {
          "generatedAt": generatedAt
        }
      )
    end

    context "when 'generatedAt' in the charge_calculation is nil" do
      let(:generatedAt) { nil }

      it "returns the correct value" do
        expect(subject.transaction_date).to eq(Date.new(2021, 8, 13))
      end
    end

    context "when 'generatedAt' in the charge_calculation is not blank" do
      let(:generatedAt) { "2021-10-01" }

      it "returns the correct value" do
        expect(subject.transaction_date).to eq("2021-10-01".to_date)
      end
    end
  end
end

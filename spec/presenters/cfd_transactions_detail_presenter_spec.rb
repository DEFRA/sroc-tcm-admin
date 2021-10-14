# frozen_string_literal: true

require "rails_helper"

RSpec.describe CfdTransactionDetailPresenter do
  let(:subject) { CfdTransactionDetailPresenter.new(transaction_detail) }
  let(:regime) { build(:regime) }
  let(:transaction_header) { build(:transaction_header, regime: regime) }

  describe "#as_json" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.as_json).to eq(
        {
          amount: "Debit (TBC)",
          can_update_category: true,
          category_locked: nil,
          confidence_level: nil,
          consent_reference: "TONY/1234/1/1",
          customer_reference: "A1234B",
          discharge: "1",
          error_message: nil,
          excluded: false,
          excluded_reason: "",
          financial_year: "FY2021",
          generated_file_date: nil,
          generated_filename: nil,
          id: nil,
          line_amount: "237.47",
          original_file_date: "29/09/21",
          original_filename: "CFDBI00123",
          period: "01/04/17 - 10/08/17",
          region: "A",
          sroc_category: nil,
          tcm_financial_year: "2021",
          tcm_transaction_reference: nil,
          temporary_cessation: "N",
          variation: 100,
          version: "1"
        }
      )
    end
  end

  describe "#charge_params" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.charge_params).to eq(
        {
          billableDays: 132,
          chargePeriod: "FY2021",
          compliancePerformanceBand: "B",
          environmentFlag: "TEST",
          financialDays: 365,
          percentageAdjustment: 100,
          permitCategoryRef: nil,
          preConstruction: false,
          temporaryCessation: false
        }
      )
    end
  end

  describe "#clean_variation_percentage" do
    context "when variation is blank" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

      it "returns the correct value" do
        expect(subject.clean_variation_percentage).to eq(100)
      end
    end

    context "when variation is not blank" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header, variation: "90%") }

      it "returns the correct value" do
        expect(subject.clean_variation_percentage).to eq("90")
      end
    end
  end

  describe "#tcm_compliance_percentage" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.tcm_compliance_percentage).to eq("")
    end
  end

  describe "#consent_reference" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.consent_reference).to eq("TONY/1234/1/1")
    end
  end

  describe "#permit_reference" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.permit_reference).to eq("TONY/1234/1/1")
    end
  end

  describe "#discharge_description" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.discharge_description).to eq("STORM SEWAGE OVERFLOW")
    end
  end

  describe "#discharge_location" do
    context "when line_attr_1 is blank" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header, line_attr_1: "") }

      it "returns the correct value" do
        expect(subject.discharge_location).to eq("Discharge Location: ")
      end
    end

    context "when line_attr_1 is not blank" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

      it "returns the correct value" do
        expect(subject.discharge_location).to eq("Discharge Location: Green Rd. Pig Disposal")
      end
    end
  end

  describe "#discharge_reference" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.discharge_reference).to eq("1")
    end
  end

  describe "#site" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.site).to eq("Green Rd. Pig Disposal")
    end
  end

  describe "#transaction_date" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.transaction_date).to eq("13-AUG-2021")
    end
  end

  describe "#version" do
    let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.version).to eq("1")
    end
  end

  describe "#variation_percentage_file" do
    context "when variation is 100%" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header, variation: "100%") }

      it "returns the correct value" do
        expect(subject.variation_percentage_file).to eq("")
      end
    end

    context "when variation is not 100%" do
      let(:transaction_detail) { build(:transaction_detail, transaction_header: transaction_header, variation: "90%") }

      it "returns the correct value" do
        expect(subject.variation_percentage_file).to eq("90%")
      end
    end
  end
end

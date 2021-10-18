# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasTransactionDetailPresenter do
  let(:subject) { PasTransactionDetailPresenter.new(transaction_detail) }
  let(:regime) { build(:regime) }
  let(:transaction_header) { build(:transaction_header, :pas, regime: regime) }

  describe "#absolute_original_permit_reference" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.absolute_original_permit_reference).to eq("ZZ1234ZZ")
    end
  end

  describe "#as_json" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.as_json).to eq(
        {
          id: nil,
          customer_reference: "A1234B",
          tcm_transaction_reference: nil,
          generated_filename: nil,
          generated_file_date: nil,
          original_filename: "PASYI00337",
          original_file_date: "29/09/21",
          permit_reference: "VP3839DA",
          original_permit_reference: "ABC1234A",
          compliance_band: "F",
          site: "Red St. Hill Farm",
          sroc_category: nil,
          confidence_level: nil,
          category_locked: nil,
          can_update_category: true,
          temporary_cessation: "N",
          financial_year: "FY2021",
          tcm_financial_year: "2021",
          region: "A",
          period: "01/04/17 - 10/08/17",
          line_amount: "237.47",
          amount: "Debit (TBC)",
          excluded: false,
          excluded_reason: "",
          error_message: nil
        }
      )
    end
  end

  describe "#charge_params" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.charge_params).to eq(
        {
          permitCategoryRef: nil,
          temporaryCessation: false,
          compliancePerformanceBand: "F",
          billableDays: 132,
          financialDays: 365,
          chargePeriod: "FY2021",
          preConstruction: false,
          environmentFlag: "TEST"
        }
      )
    end
  end

  describe "#compliance_band" do
    let(:transaction_detail) do
      build(:transaction_detail, :pas, transaction_header: transaction_header, line_attr_11: line_attr_11)
    end

    context "when line_attr_11 is blank" do
      let(:line_attr_11) { "" }

      it "returns the correct value" do
        expect(subject.compliance_band).to eq("")
      end
    end

    context "when line_attr_11 is not blank" do
      let(:line_attr_11) { "F 3.0" }

      it "returns the correct value" do
        expect(subject.compliance_band).to eq("F")
      end
    end
  end

  describe "#compliance_band_adjustment" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.compliance_band_adjustment).to eq("")
    end
  end

  describe "#original_permit_reference" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.original_permit_reference).to eq("ABC1234A")
    end
  end

  describe "#permit_reference" do
    let(:transaction_detail) { build(:transaction_detail, :pas, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.permit_reference).to eq("VP3839DA")
    end
  end

  describe "#site" do
    let(:transaction_detail) do
      build(:transaction_detail, :pas, transaction_header: transaction_header)
    end

    it "returns the correct value" do
      expect(subject.site).to eq("Red St. Hill Farm")
    end
  end

  describe "#site_address" do
    let(:transaction_detail) do
      build(:transaction_detail, :pas, transaction_header: transaction_header)
    end

    it "returns the correct value" do
      expect(subject.site_address).to eq("Site: Red St. Hill Farm, , , , ,AB12 1AB")
    end
  end
end

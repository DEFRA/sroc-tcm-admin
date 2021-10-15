# frozen_string_literal: true

require "rails_helper"

RSpec.describe WmlTransactionDetailPresenter do
  let(:subject) { WmlTransactionDetailPresenter.new(transaction_detail) }
  let(:regime) { build(:regime) }
  let(:transaction_header) { build(:transaction_header, :wml, regime: regime) }

  describe "#as_json" do
    let(:transaction_detail) { build(:transaction_detail, :wml, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.as_json).to eq(
        {
          id: nil,
          customer_reference: "A1234B",
          tcm_transaction_reference: nil,
          generated_filename: nil,
          generated_file_date: nil,
          original_filename: "WMLEI07892",
          original_file_date: "29/09/21",
          permit_reference: "026101",
          compliance_band: "",
          sroc_category: "2.15.2",
          confidence_level: nil,
          category_locked: nil,
          can_update_category: true,
          temporary_cessation: "N",
          tcm_financial_year: "2021",
          period: "01/04/17 - 10/08/17",
          amount: "Debit (TBC)",
          excluded: false,
          excluded_reason: "",
          error_message: nil
        }
      )
    end
  end

  describe "#compliance_band" do
    context "when line_attr_6 is blank" do
      let(:transaction_detail) do
        build(:transaction_detail, :wml, transaction_header: transaction_header)
      end

      it "returns the correct value" do
        expect(subject.compliance_band).to eq("")
      end
    end

    context "when line_attr_6 is not blank" do
      let(:transaction_detail) do
        build(:transaction_detail, :wml, transaction_header: transaction_header, line_attr_6: "A(95%)")
      end

      it "returns the correct value" do
        expect(subject.compliance_band).to eq("A")
      end
    end
  end

  describe "#compliance_band_with_percent" do
    test_data = [
      { example: "'nil'", band: nil, expected: "" },
      { example: "'(100%)'", band: "(100%)", expected: "" },
      { example: "'A(95%)'", band: "A(95%)", expected: "A (95%)" },
      { example: "'Significant Improvement Needed(100%)'", band: "Significant Improvement Needed(100%)", expected: "Significant Improvement Needed (100%)" }
    ]

    test_data.each do |data|
      context "when 'compliancePerformanceBand' in the charge_calculation is #{data[:example]}" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            :wml,
            transaction_header: transaction_header,
            charge_calculation: {
              "calculation": {
                "compliancePerformanceBand": data[:band]
              }
            }
          )
        end

        it "returns the correct value" do
          expect(subject.compliance_band_with_percent).to eq(data[:expected])
        end
      end
    end
  end

  describe "#credit_line_description" do
    let(:transaction_detail) do
      build(:transaction_detail, :wml, transaction_header: transaction_header, line_description: line_description)
    end

    context "when line_description is 'nil'" do
      let(:line_description) { nil }

      it "returns 'nil'" do
        expect(subject.credit_line_description).to be_nil
      end
    end

    context "when line_description is not 'nil'" do
      let(:line_description) { "Hello, world!" }

      context "and it contains the phrase 'Permit Ref:'" do
        let(:line_description) do
          "In cancellation of invoice no. E01181293: Credit of subsistence charge due to the licence being "\
          "surrendered.wef 6/3/2018 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, "\
          "Permit Ref: XZ3333PG/A001"
        end

        it "replaces it with 'EPR Ref:'" do
          expect(subject.credit_line_description).to include("EPR Ref:")
          expect(subject.credit_line_description).not_to include("Permit Ref:")
        end
      end

      context "and it contains the word 'due'" do
        let(:line_description) do
          "In cancellation of invoice no. E01181293: Credit of subsistence charge due to the licence being "\
          "surrendered.wef 6/3/2018 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, "\
          "Permit Ref: XZ3333PG/A001"
        end

        it "adds it and everything after it to the end of the standard prefix" do
          expect(subject.credit_line_description).to eq(
            "Credit of subsistence charge for permit category 2.15.2 due to the licence being surrendered.wef "\
            "6/3/2018 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, EPR Ref: XZ3333PG/A001")
        end
      end

      context "and it doesn't contain the word 'due'" do
        context "but does contain the word 'at'" do
          let(:line_description) do
            "In cancellation of invoice no. B01191428: Credit of Charge Code 1 at Rookery Road, St Georges, Telford, "\
            "TF2 9BW, Permit Ref: FB3404FL/"
          end

          it "capitilises 'at' and adds everything after it to the end of the standard prefix" do
            expect(subject.credit_line_description).to eq(
              "Credit of subsistence charge for permit category 2.15.2. At Rookery Road, St Georges, Telford, "\
              "TF2 9BW, EPR Ref: FB3404FL/"
            )
          end
        end

        context "nor the word 'at'" do
          let(:line_description) do
            "In cancellation of invoice no. B01191428: Credit of Charge Code 1 on Rookery Road, St Georges, Telford, "\
            "TF2 9BW, Permit Ref: FB3404FL/"
          end

          it "drops the start of the original line_description" do
            expect(subject.credit_line_description).to eq(
              "Credit of subsistence charge for permit category 2.15.2. Credit of Charge Code 1 on Rookery Road, St "\
              "Georges, Telford, TF2 9BW, EPR Ref: FB3404FL/"
            )
            expect(subject.credit_line_description).not_to include("In cancellation of invoice no. B01191428: ")
          end
        end
      end

      context "and doesn't contain the words 'due', 'at' or start with 'In cancellation of invoice no. '" do
        it "just puts the existing description after the standard prefix" do
          expect(subject.credit_line_description).to eq(
            "Credit of subsistence charge for permit category 2.15.2. Hello, world!"
          )
        end
      end

      it "always starts with a standard prefix that includes the category" do
        expect(subject.credit_line_description).to start_with(
          "Credit of subsistence charge for permit category 2.15.2"
        )
      end
    end
  end

  describe "#invoice_line_description" do
    let(:transaction_detail) do
      build(:transaction_detail, :wml, transaction_header: transaction_header, line_description: line_description)
    end

    context "when line_description is 'nil'" do
      let(:line_description) { nil }

      it "returns 'nil'" do
        expect(subject.invoice_line_description).to be_nil
      end
    end

    context "when line_description is not 'nil'" do
      let(:line_description) { "Hello, world!" }

      context "and it contains the phrase 'Permit Ref:'" do
        let(:line_description) do
          "Charge Code 1 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, Permit Ref: XZ3333PG/A001"
        end

        it "replaces it with 'EPR Ref:'" do
          expect(subject.invoice_line_description).to include("EPR Ref:")
          expect(subject.invoice_line_description).not_to include("Permit Ref:")
        end
      end

      context "and it contains the word 'at'" do
        let(:line_description) do
          "Charge Code 1 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, Permit Ref: XZ3333PG/A001"
        end

        it "drops and everything up to it then adds the remainder to a 'Site:' prefix" do
          expect(subject.invoice_line_description).to eq(
            "Site: Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, EPR Ref: XZ3333PG/A001"
          )
        end
      end

      context "and it doesn't contain the word 'at'" do
        let(:line_description) do
          "Compliance adjustment for Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, "\
          "Permit Ref: XXX/123"
        end

        it "returns the original line_description with just the word 'Permit' replaced by 'EPR'" do
          expect(subject.invoice_line_description).to eq(
            "Compliance adjustment for Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, "\
            "EPR Ref: XXX/123"
          )
        end
      end
    end
  end

  describe "#permit_reference" do
    let(:transaction_detail) { build(:transaction_detail, :wml, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.permit_reference).to eq("026101")
    end
  end
end

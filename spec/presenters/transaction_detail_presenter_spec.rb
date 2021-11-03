# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransactionDetailPresenter do
  let(:subject) { TransactionDetailPresenter.new(transaction_detail) }
  let(:regime) { build(:regime) }
  let(:transaction_header) { build(:transaction_header, regime: regime) }

  describe "#amount" do
    let(:transaction_detail) do
      build(
        :transaction_detail,
        :cfd,
        transaction_header: transaction_header,
        tcm_charge: tcm_charge,
        charge_calculation: charge_calculation
      )
    end

    context "when a charge_calculation is 'nil'" do
      let(:tcm_charge) { nil }
      let(:charge_calculation) { nil }

      it "returns the correct value" do
        expect(subject.amount).to eq("Debit (TBC)")
      end
    end

    context "when a charge_calculation is set" do
      let(:charge_calculation) { { "calculation": {} } }

      context "and tcm_charge is set" do
        let(:tcm_charge) { 23_747 }

        it "returns the correct value" do
          expect(subject.amount).to eq("237.47")
        end
      end

      context "but tcm_charge is 'nil" do
        let(:tcm_charge) { nil }

        it "returns the correct value" do
          expect(subject.amount).to eq("Debit (TBC)")
        end
      end
    end
  end

  describe "#approved_date" do
    let(:approved_for_billing_at) { Date.new(2021, 9, 29) }
    let(:transaction_detail) do
      build(
        :transaction_detail,
        :cfd,
        transaction_header: transaction_header,
        approved_for_billing_at: approved_for_billing_at
      )
    end

    it "returns the correct value" do
      expect(subject.approved_date).to eq(approved_for_billing_at)
    end
  end

  describe "#approved_flag" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, approved_for_billing: approved_for_billing)
    end

    context "when approved_for_billing is 'true'" do
      let(:approved_for_billing) { true }

      it "returns the correct value" do
        expect(subject.approved_flag).to eq("Y")
      end
    end

    context "when approved_for_billing is 'false'" do
      let(:approved_for_billing) { false }

      it "returns the correct value" do
        expect(subject.approved_flag).to eq("N")
      end
    end
  end

  describe "#error_message" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, charge_calculation: charge_calculation)
    end

    context "when a charge_calculation is 'nil'" do
      let(:charge_calculation) { nil }

      it "returns 'nil'" do
        expect(subject.error_message).to be_nil
      end
    end

    context "when a charge_calculation is set" do
      context "and has a single message against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "messages": "Oops, I did it again"
            }
          }
        end

        it "returns the correct value" do
          expect(subject.error_message).to eq("Oops, I did it again")
        end
      end

      context "and has a multiple messages against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "messages": [
                "Oops, I did it again",
                "I played with your heart",
                "Got lost in the game"
              ]
            }
          }
        end

        it "returns the correct value" do
          expect(subject.error_message).to eq(
            "Oops, I did it again\\nI played with your heart\\nGot lost in the game"
          )
        end
      end

      context "but doesn't have a message against it" do
        let(:charge_calculation) { { "calculation": {} } }

        it "returns the correct value" do
          expect(subject.error_message).to eq(nil)
        end
      end
    end
  end

  describe "#baseline_charge" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, charge_calculation: charge_calculation)
    end

    context "when a charge_calculation is 'nil'" do
      let(:charge_calculation) { nil }

      it "returns 'nil'" do
        expect(subject.baseline_charge).to be_nil
      end
    end

    context "when a charge_calculation is set" do
      context "but has a message against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "messages": "Oops, I did it again"
            }
          }
        end

        it "returns 'nil'" do
          expect(subject.baseline_charge).to be_nil
        end
      end

      context "and doesn't have a message against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "decisionPoints": {
                "baselineCharge": 2.457
              }
            }
          }
        end

        it "returns the correct value" do
          expect(subject.baseline_charge).to eq(246)
        end
      end
    end
  end

  describe "#billable_days" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.billable_days).to eq(132)
    end

    it "matches the second part of the transaction's line_attr_4" do
      billable_days_part = transaction_detail.line_attr_4.split("/")[1].to_i

      expect(subject.billable_days).to eq(billable_days_part)
    end
  end

  describe "#calculated_amount" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.calculated_amount).to eq(23_747)
    end
  end

  describe "#can_update_category?" do
    let(:suggested_category) { build(:suggested_category, admin_lock: admin_lock) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    context "if the suggested_category has admin_lock set to 'false'" do
      let(:admin_lock) { false }

      it "returns the correct value" do
        expect(subject.can_update_category?).to eq(true)
      end
    end

    context "if the suggested_category has admin_lock set to 'true'" do
      let(:admin_lock) { true }
      let(:subject) { TransactionDetailPresenter.new(transaction_detail, user) }

      context "and the user is an admin" do
        let(:user) { build(:user, :admin) }

        it "returns the correct value" do
          expect(subject.can_update_category?).to eq(true)
        end
      end

      context "and the user is not an admin" do
        let(:user) { build(:user, :billing) }

        it "returns the correct value" do
          expect(subject.can_update_category?).to eq(false)
        end
      end
    end
  end

  describe "#category_description" do
    context "when category_description is not blank" do
      let(:transaction_detail) do
        build(:transaction_detail, :cfd, transaction_header: transaction_header, category_description: "category stuff")

        it "returns category_description" do
          expect(subject.category_description).to eq("category stuff")
        end
      end
    end

    context "when category_description is blank" do
      context "and the status is 'unbilled'" do
        let(:transaction_detail) do
          build(:transaction_detail, :cfd, transaction_header: transaction_header, category: "2.3.4")
        end

        before(:each) do
          allow_any_instance_of(PermitStorageService).to receive(:code_for_financial_year).and_return(permit_category)
        end

        context "and category is set to something recognisable" do
          let(:permit_category) { build(:permit_category) }

          it "returns the permit categories description" do
            expect(subject.category_description).to eq(permit_category.description)
          end
        end

        context "but category is set to something not recognised" do
          let(:permit_category) { nil }

          it "returns 'nil'" do
            expect(subject.category_description).to be_nil
          end
        end
      end

      context "but status is not 'unbilled'" do
        let(:transaction_detail) do
          build(:transaction_detail, :cfd, transaction_header: transaction_header, status: "exported")
        end

        it "returns 'nil'" do
          expect(subject.category_description).to be_nil
        end
      end

      context "but category is not set" do
        let(:transaction_detail) do
          build(:transaction_detail, :cfd, transaction_header: transaction_header, category: nil)

          it "returns 'nil'" do
            expect(subject.category_description).to be_nil
          end
        end
      end
    end
  end

  describe "#category_locked" do
    let(:suggested_category) { build(:suggested_category) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.category_locked).to eq(false)
    end
  end

  describe "#charge_amount" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.charge_amount).to eq(23_747)
    end
  end

  describe "#charge_period" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.charge_period).to eq("FY2021")
    end
  end

  describe "#confidence_level" do
    let(:suggested_category) { build(:suggested_category) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.confidence_level).to eq("red")
    end
  end

  describe "#credit_debit" do
    test_data = [
      { line_amount: -1, status: "unbilled", expected: "Credit (TBC)" },
      { line_amount: 1, status: "unbilled", expected: "Debit (TBC)" },
      { line_amount: 0, status: "unbilled", expected: "Debit (TBC)" },
      { line_amount: -1, status: "excluded", expected: "Credit" },
      { line_amount: 1, status: "excluded", expected: "Debit" },
      { line_amount: 0, status: "excluded", expected: "Debit" }
    ]

    test_data.each do |data|
      context "when line_amount is #{data[:line_amount]} and status is '#{data[:status]}'" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            :cfd,
            transaction_header: transaction_header,
            line_amount: data[:line_amount],
            status: data[:status]
          )
        end

        it "returns the correct value" do
          expect(subject.credit_debit).to eq(data[:expected])
        end
      end
    end
  end

  describe "#credit_debit_indicator" do
    test_data = [
      { line_amount: -1, expected: "C" },
      { line_amount: 1, expected: "D" },
      { line_amount: 0, expected: "D" }
    ]

    test_data.each do |data|
      context "when line_amount is #{data[:line_amount]}" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            :cfd,
            transaction_header: transaction_header,
            line_amount: data[:line_amount]
          )
        end

        it "returns the correct value" do
          expect(subject.credit_debit_indicator).to eq(data[:expected])
        end
      end
    end
  end

  describe "#currency_baseline_charge" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, charge_calculation: charge_calculation)
    end

    context "when a charge_calculation is 'nil'" do
      let(:charge_calculation) { nil }

      it "returns 'nil'" do
        expect(subject.currency_baseline_charge).to eq("")
      end
    end

    context "when a charge_calculation is set" do
      context "but has a message against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "messages": "Oops, I did it again"
            }
          }
        end

        it "returns 'nil'" do
          expect(subject.currency_baseline_charge).to eq("")
        end
      end

      context "and doesn't have a message against it" do
        let(:charge_calculation) do
          {
            "calculation": {
              "decisionPoints": {
                "baselineCharge": 2.457
              }
            }
          }
        end

        it "returns the correct value" do
          expect(subject.currency_baseline_charge).to eq("2.46")
        end
      end
    end
  end

  describe "#currency_line_amount" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.currency_line_amount).to eq("237.47")
    end
  end

  describe "#currency_unit_of_measure_price" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.currency_unit_of_measure_price).to eq("237.47")
    end
  end

  describe "#currency_tcm_charge" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, tcm_charge: tcm_charge)
    end

    context "when a tcm_charge is 'nil'" do
      let(:tcm_charge) { nil }

      it "returns the correct value" do
        expect(subject.currency_tcm_charge).to eq("")
      end
    end

    context "when a tcm_charge is not 'nil'" do
      let(:tcm_charge) { 23_747 }

      it "returns the correct value" do
        expect(subject.currency_tcm_charge).to eq("237.47")
      end
    end
  end

  describe "#customer_name" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, customer_name: customer_name)
    end

    context "when customer_name is 'nil'" do
      let(:customer_name) { nil }

      it "returns the correct value" do
        expect(subject.customer_name).to eq("")
      end
    end

    context "when customer_name is set" do
      let(:customer_name) { "Mr Tumble" }

      it "returns the correct value" do
        expect(subject.customer_name).to eq("Mr Tumble")
      end
    end
  end

  describe "#date_received" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, created_at: Date.new(2021, 8, 13))
    end

    it "returns the correct value" do
      expect(subject.date_received).to eq("13-AUG-2021")
    end
  end

  describe "#editable?" do
    test_data = [
      { status: "excluded", excluded: true, approved: true, expected: false },
      { status: "excluded", excluded: true, approved: false, expected: false },
      { status: "excluded", excluded: false, approved: true, expected: false },
      { status: "excluded", excluded: false, approved: false, expected: false },
      { status: "unbilled", excluded: true, approved: true, expected: false },
      { status: "unbilled", excluded: true, approved: false, expected: false },
      { status: "unbilled", excluded: false, approved: true, expected: false },
      { status: "unbilled", excluded: false, approved: false, expected: true }
    ]

    test_data.each do |data|
      context "when status is '#{data[:status]}', excluded is '#{data[:excluded]}' and approved_for_billing is '#{data[:approved]}'" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            :cfd,
            transaction_header: transaction_header,
            status: data[:status],
            excluded: data[:excluded],
            approved_for_billing: data[:approved]
          )
        end

        it "returns the correct value" do
          expect(subject.editable?).to eq(data[:expected])
        end
      end
    end
  end

  describe "#excluded_flag" do
    test_data = [
      { status: "excluded", excluded: true, expected: "Y" },
      { status: "excluded", excluded: false, expected: "Y" },
      { status: "unbilled", excluded: true, expected: "Y" },
      { status: "unbilled", excluded: false, expected: "N" }
    ]

    test_data.each do |data|
      context "when status is '#{data[:status]}' and excluded is '#{data[:excluded]}'" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            transaction_header: transaction_header,
            status: data[:status],
            excluded: data[:excluded]
          )
        end

        it "returns the correct value" do
          expect(subject.excluded_flag).to eq(data[:expected])
        end
      end
    end
  end

  describe "#excluded_reason" do
    test_data = [
      { status: "excluded", excluded: "true", expected: "No shirt, no entry" },
      { status: "excluded", excluded: "false", expected: "No shirt, no entry" },
      { status: "unbilled", excluded: "true", expected: "No shirt, no entry" },
      { status: "unbilled", excluded: "false", expected: "" }
    ]

    test_data.each do |data|
      context "when status is '#{data[:status]}' and excluded is '#{data[:excluded]}'" do
        let(:transaction_detail) do
          build(
            :transaction_detail,
            :cfd,
            transaction_header: transaction_header,
            excluded_reason: "No shirt, no entry",
            status: data[:status],
            excluded: data[:excluded]
          )
        end

        it "returns the correct value" do
          expect(subject.excluded_reason).to eq(data[:expected])
        end
      end
    end
  end

  describe "#file_reference" do
    let(:transaction_header) { build(:transaction_header, regime: regime, file_reference: "CFDTI00999") }
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.file_reference).to eq("CFDTI00999")
    end
  end

  describe "#financial_year" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.financial_year).to eq(2017)
    end
  end

  describe "#financial_year_days" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.financial_year_days).to eq(365)
    end

    it "matches the first part of the transaction's line_attr_4" do
      financial_year_days_part = transaction_detail.line_attr_4.split("/")[0].to_i

      expect(subject.financial_year_days).to eq(financial_year_days_part)
    end
  end

  describe "#generated_at" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.generated_at).to eq("13-AUG-2021")
    end
  end

  describe "#generated_file_date" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, generated_file_at: generated_file_at)
    end

    context "when a generated_file_at is 'nil'" do
      let(:generated_file_at) { nil }

      it "returns the correct value" do
        expect(subject.generated_file_date).to be_nil
      end
    end

    context "when a generated_file_at is set" do
      let(:generated_file_at) { Date.new(2021, 9, 29) }

      it "returns the correct value" do
        expect(subject.generated_file_date).to eq("29/09/21")
      end
    end
  end

  describe "#original_charge" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.original_charge).to eq("237.47")
    end
  end

  describe "#original_file_date" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.original_file_date).to eq("29-SEP-2021")
    end
  end

  describe "#original_file_date_table" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.original_file_date_table).to eq("29/09/21")
    end
  end

  describe "#original_transaction_date" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.original_transaction_date).to eq(Date.new(2021, 8, 13))
    end
  end

  describe "#period" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.period).to eq("01/04/17 - 10/08/17")
    end
  end

  describe "#period_start" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.period_start).to eq("1-APR-2017")
    end
  end

  describe "#period_end" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.period_end).to eq("10-AUG-2017")
    end
  end

  describe "#pre_sroc_flag" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, status: status)
    end

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

  describe "#pretty_status" do
    let(:transaction_detail) { build(:transaction_detail, :cfd, transaction_header: transaction_header) }

    it "returns the correct value" do
      expect(subject.pretty_status).to eq("Unbilled")
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

  describe "#suggested_category_admin_lock_flag" do
    let(:suggested_category) { build(:suggested_category, admin_lock: admin_lock) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    context "when admin_lock in the suggested_category is 'true'" do
      let(:admin_lock) { true }

      it "returns the correct value" do
        expect(subject.suggested_category_admin_lock_flag).to eq("Y")
      end
    end

    context "when admin_lock in the suggested_category is 'false'" do
      let(:admin_lock) { false }

      it "returns the correct value" do
        expect(subject.suggested_category_admin_lock_flag).to eq("N")
      end
    end
  end

  describe "#suggested_category_code" do
    let(:suggested_category) { build(:suggested_category, category: "2.3.4") }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.suggested_category_code).to eq("2.3.4")
    end
  end

  describe "#suggested_category_confidence_level" do
    let(:suggested_category) { build(:suggested_category) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.suggested_category_confidence_level).to eq("Red")
    end
  end

  describe "#suggested_category_logic" do
    let(:suggested_category) { build(:suggested_category) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.suggested_category_logic).to eq("No previous bill found")
    end
  end

  describe "#suggested_category_stage" do
    let(:suggested_category) { build(:suggested_category) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    it "returns the correct value" do
      expect(subject.suggested_category_stage).to eq("Annual billing - stage 2")
    end
  end

  describe "#suggested_category_overridden_flag" do
    let(:suggested_category) { build(:suggested_category, overridden: overridden) }
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, suggested_category: suggested_category)
    end

    context "when overridden in the suggested_category is 'true'" do
      let(:overridden) { true }

      it "returns the correct value" do
        expect(subject.suggested_category_overridden_flag).to eq("Y")
      end
    end

    context "when overridden in the suggested_category is 'false'" do
      let(:overridden) { false }

      it "returns the correct value" do
        expect(subject.suggested_category_overridden_flag).to eq("N")
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
            :cfd,
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

  describe "#tcm_file_date" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, transaction_file: transaction_file)
    end

    context "when a transaction_file exists" do
      let(:transaction_file) { build(:transaction_file, created_at: Date.new(2021, 9, 29)) }

      it "returns the correct value" do
        expect(subject.tcm_file_date).to eq("29-SEP-2021")
      end
    end

    context "when a transaction_file doesn't exist" do
      let(:transaction_file) { nil }

      it "returns the correct value" do
        expect(subject.tcm_file_date).to eq("")
      end
    end
  end

  describe "#temporary_cessation_file" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, temporary_cessation: temporary_cessation)
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
      build(:transaction_detail, :cfd, transaction_header: transaction_header, temporary_cessation: temporary_cessation)
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

  describe "#temporary_cessation_yes_no" do
    let(:transaction_detail) do
      build(:transaction_detail, :cfd, transaction_header: transaction_header, temporary_cessation: temporary_cessation)
    end

    context "when temporary_cessation is true" do
      let(:temporary_cessation) { true }

      it "returns the correct value" do
        expect(subject.temporary_cessation_yes_no).to eq("Yes")
      end
    end

    context "when temporary_cessation is false" do
      let(:temporary_cessation) { false }

      it "returns the correct value" do
        expect(subject.temporary_cessation_yes_no).to eq("No")
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

  describe ".wrap" do
    let(:transactions) do
      [
        build(:transaction_detail, :cfd, transaction_header: transaction_header),
        build(:transaction_detail, :cfd, transaction_header: transaction_header)
      ]
    end

    it "returns a collection containing a TransactionDetailPresenter for each TransactionDetail" do
      result = TransactionDetailPresenter.wrap(transactions)

      expect(result.length).to eq(2)
      expect(result[0]).to be_a(TransactionDetailPresenter)
      expect(result[0].transaction_reference).to eq(transactions[0].transaction_reference)
    end
  end
end

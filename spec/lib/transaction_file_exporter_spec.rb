# frozen_string_literal: true

require "rails_helper"

class Filters
  include TransactionGroupFilters

  attr_reader :regime, :region, :user

  def initialize(regime, region, user)
    @regime = regime
    @region = region
    @user = user
  end
end

RSpec.describe TransactionFileExporter do
  let(:regime) { create(:regime) }
  let(:region) { "A" }
  let(:user) { create(:user_with_regime, :billing, regime: regime) }
  let(:service) { TransactionFileExporter.new(regime, region, user) }

  describe "#export" do
    let(:export) { service.export }

    it "creates an audit record" do
      expect { export }.to change { AuditLog.count }.by 1

      last_audit_log = AuditLog.last

      expect(last_audit_log.action).to eq("create")
      expect(last_audit_log.id).to eq(TransactionFile.last.audit_logs.last.id)
    end

    context "when there are no transaction records" do
      it "still adds a transaction file record to the db" do
        expect { export }.to change { TransactionFile.count }.by 1
      end
    end

    context "when there are transaction records" do
      let(:transaction_header) { create(:transaction_header, regime: regime) }

      context "but they are not approved" do
        let!(:transaction_detail) { create(:transaction_detail, transaction_header: transaction_header) }

        it "still adds a transaction file record to the db" do
          expect { export }.to change { TransactionFile.count }.by 1
        end

        it "doesn't include them in the export" do
          service.export

          last_transaction_file = TransactionFile.last

          expect(last_transaction_file.credit_count).to eq(0)
          expect(last_transaction_file.debit_count).to eq(0)
        end
      end

      context "and they are approved" do
        let!(:transaction_detail) do
          create(:transaction_detail, :approved, approver: user, transaction_header: transaction_header)
        end

        it "adds a transaction file record to the db" do
          expect { export }.to change { TransactionFile.count }.by 1
        end

        it "includes them in the export" do
          service.export

          last_transaction_file = TransactionFile.last

          expect(last_transaction_file.credit_count).to eq(0)
          expect(last_transaction_file.debit_count).to eq(1)
        end

        it "records the current user against the transaction file record" do
          service.export

          expect(TransactionFile.last.user).to eq(user)
        end
      end
    end
  end

  describe "#generate_output_file" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let(:permit_category) { create(:permit_category, regime: regime) }
    let!(:transaction_detail) do
      create(
        :transaction_detail,
        :approved,
        approver: user,
        category: permit_category.code,
        transaction_header: transaction_header
      )
    end
    let(:s3_regex) { Helpers::S3Helpers.any_request }

    before(:each) { stub_request(:put, s3_regex) }

    it "sets the permit category description on the transaction detail" do
      transaction_file = service.export
      service.generate_output_file(transaction_file)

      expect(TransactionDetail.last.category_description).to eq(permit_category.description)
    end

    it "sets the transaction file to 'exported'" do
      transaction_file = service.export
      service.generate_output_file(transaction_file)

      expect(transaction_file.state).to eq("exported")
    end
  end

  describe "#assign_cfd_transaction_references" do
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[0],
          tcm_financial_year: financial_years[0],
          line_context_code: line_context_codes[0],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[1],
          tcm_financial_year: financial_years[1],
          line_context_code: line_context_codes[1],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[2],
          tcm_financial_year: financial_years[2],
          line_context_code: line_context_codes[2],
          transaction_header: transaction_header
        )
      ]
    end

    context "when the transaction details have different customer references" do
      let(:customer_references) { %w[A1234B B1234B C1234B] }
      let(:financial_years) { Array.new(3, 2018) }
      let(:line_context_codes) { Array.new(3, "A") }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_cfd_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details have different financial years" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { [2018, 2019, 2020] }
      let(:line_context_codes) { Array.new(3, "A") }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_cfd_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details have different line context codes" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { Array.new(3, 2018) }
      let(:line_context_codes) { %w[A B C] }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_cfd_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end
  end

  describe "#assign_wml_transaction_references" do
    let(:regime) { create(:regime, :wml) }
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[0],
          tcm_financial_year: financial_years[0],
          tcm_charge: tcm_charges[0],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[1],
          tcm_financial_year: financial_years[1],
          tcm_charge: tcm_charges[1],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[2],
          tcm_financial_year: financial_years[2],
          tcm_charge: tcm_charges[2],
          transaction_header: transaction_header
        )
      ]
    end

    context "when the transaction details have different customer references" do
      let(:customer_references) { %w[A1234B B1234B C1234B] }
      let(:financial_years) { Array.new(3, 2018) }
      let(:tcm_charges) { Array.new(3, 23_747) }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_wml_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details have different financial years" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { [2018, 2019, 2020] }
      let(:tcm_charges) { Array.new(3, 23_747) }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_wml_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details are a mix of credits and debits" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { Array.new(3, 2018) }
      let(:tcm_charges) { [23_747, -23_747, 23_747] }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_wml_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(2)
      end
    end
  end

  describe "#assign_pas_transaction_references" do
    let(:regime) { create(:regime, :pas) }
    let(:transaction_header) { create(:transaction_header, regime: regime) }
    let!(:transaction_details) do
      [
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[0],
          tcm_financial_year: financial_years[0],
          tcm_charge: tcm_charges[0],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[1],
          tcm_financial_year: financial_years[1],
          tcm_charge: tcm_charges[1],
          transaction_header: transaction_header
        ),
        create(
          :transaction_detail,
          :approved,
          approver: user,
          customer_reference: customer_references[2],
          tcm_financial_year: financial_years[2],
          tcm_charge: tcm_charges[2],
          transaction_header: transaction_header
        )
      ]
    end

    context "when the transaction details have different customer references" do
      let(:customer_references) { %w[A1234B B1234B C1234B"] }
      let(:financial_years) { Array.new(3, 2018) }
      let(:tcm_charges) { Array.new(3, 23_747) }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_pas_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details have different financial years" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { [2018, 2019, 2020] }
      let(:tcm_charges) { Array.new(3, 23_747) }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_pas_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(3)
      end
    end

    context "when the transaction details are a mix of credits and debits" do
      let(:customer_references) { Array.new(3, "A1234B") }
      let(:financial_years) { Array.new(3, 2018) }
      let(:tcm_charges) { [23_747, -23_747, 23_747] }

      it "assigns a different transaction reference to each one" do
        transaction_file = service.export
        service.assign_pas_transaction_references(transaction_file)

        transaction_details.each do |transaction_detail|
          transaction_detail.reload
          expect(transaction_detail.tcm_transaction_reference).not_to be_nil
        end

        expect(transaction_details.uniq(&:tcm_transaction_reference).length).to eq(2)
      end
    end
  end
end

# frozen_string_literal: true

require "test_helper"

class CfdTransactionFilePresenterTest < ActiveSupport::TestCase
  include TransactionFileFormat

  def setup
    @user = users(:billing_admin)
    Thread.current[:current_user] = @user

    @transaction1 = transaction_details(:cfd)
    @transaction2 = @transaction1.dup

    @transaction2.customer_reference = "A1234000A"
    @transaction2.transaction_type = "C"
    @transaction2.line_description = "Consent No - ABCD/9999/1/2"
    @transaction2.reference_1 = "ABCD/9999/1/2"
    @transaction2.line_amount = -1234
    @transaction2.unit_of_measure_price = -1234

    [@transaction1, @transaction2].each do |t|
      t.category = "2.3.4"
      t.status = "billed"
      t.tcm_charge = t.line_amount
      apply_charge_calculation(t)
    end

    @file = transaction_files(:cfd_sroc_file)
    @file.transaction_details << @transaction1
    @file.transaction_details << @transaction2

    @presenter = CfdTransactionFilePresenter.new(@file)
  end

  def apply_charge_calculation(transaction)
    transaction.charge_calculation = {
      "calculation" => {
        "chargeAmount" => transaction.tcm_charge.abs,
        "decisionPoints" => {
          "baselineCharge" => 196_803,
          "percentageAdjustment" => 0
        }
      },
      "generatedAt" => "10-AUG-2017"
    }
    transaction.save
  end
end

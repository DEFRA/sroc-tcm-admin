# frozen_string_literal: true

require "test_helper"

class PasTransactionFilePresenterTest < ActiveSupport::TestCase
  include TransactionFileFormat

  def setup
    @user = users(:billing_admin)
    Thread.current[:current_user] = @user

    @transaction1 = transaction_details(:pas)
    @transaction2 = @transaction1.dup

    @transaction2.customer_reference = "A223344123P"
    @transaction2.transaction_reference = "PAS00055512Y"
    @transaction2.transaction_type = "C"
    @transaction2.reference_1 = "VP1234AA"
    @transaction2.line_amount = -1234
    @transaction2.unit_of_measure_price = -1234

    [@transaction1, @transaction2].each_with_index do |t, i|
      t.category = "2.4.4"
      t.status = "billed"
      t.tcm_charge = t.line_amount
      t.tcm_transaction_type = t.transaction_type
      t.tcm_transaction_reference = generate_reference(t, 100 - i)
      apply_charge_calculation(t, "A(#{rand(50..100)}%)")
    end

    @file = transaction_files(:pas_sroc_file)
    @file.transaction_details << @transaction1
    @file.transaction_details << @transaction2

    @presenter = PasTransactionFilePresenter.new(@file)
  end

  def test_it_sorts_detail_rows_by_tcm_transaction_reference
    rows = []
    @presenter.details do |row|
      rows << row
    end
    sorted_rows = [@transaction1, @transaction2].sort do |a, b|
      a.tcm_transaction_reference <=> b.tcm_transaction_reference
    end

    rows.each_with_index do |r, i|
      assert_equal(sorted_rows[i].tcm_transaction_reference, r[Detail::TransactionReference])
    end
  end

  def apply_charge_calculation(transaction, band)
    transaction.charge_calculation = {
      "calculation" => {
        "chargeAmount" => transaction.tcm_charge.abs,
        "compliancePerformanceBand" => band,
        "decisionPoints" => {
          "baselineCharge" => 196_803,
          "percentageAdjustment" => 0
        }
      },
      "generatedAt" => "10-AUG-2017"
    }
    transaction.save!
  end

  def generate_reference(transaction, num)
    "PAS#{num.to_s.rjust(8, '0')}#{transaction.transaction_header.region}T"
  end
end

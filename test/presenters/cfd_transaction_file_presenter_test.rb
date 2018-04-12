require 'test_helper.rb'

class CfdTransactionFilePresenterTest < ActiveSupport::TestCase
  def setup
    @transaction_1 = transaction_details(:cfd)
    @transaction_2 = @transaction_1.dup

    @transaction_2.customer_reference ='A1234000A'
    @transaction_2.transaction_type = 'C'
    @transaction_2.line_description = 'Consent No - ABCD/9999/1/2'
    @transaction_2.reference_1 = 'ABCD/9999/1/2'
    @transaction_2.line_amount = -1234
    @transaction_2.unit_of_measure_price = -1234

    [@transaction_1, @transaction_2].each do |t|
      t.category = '2.3.4'
      t.status = 'billed'
      t.tcm_charge = t.line_amount
      set_charge_calculation(t)
    end

    @file = transaction_files(:cfd_sroc_file)
    @file.transaction_details << @transaction_1
    @file.transaction_details << @transaction_2

    @presenter = CfdTransactionFilePresenter.new(@file)
  end

  def test_it_returns_a_header_record
    assert_equal(
      [
        "H",
        "0000000",
        "CFD",
        "B",
        "I",
        @file.file_id,
        "",
        @file.generated_at.strftime("%-d-%^b-%Y")
      ],
      @presenter.header
    )
  end

  def test_it_produces_detail_records
    rows = []
    @presenter.details do |row|
      rows << row
    end
    assert_equal(2, rows.count)
  end

  def test_detail_records_have_correct_line_attr_4_pro_rata_days
    @presenter.transaction_details.each_with_index do |td, i|
      p = CfdTransactionDetailPresenter.new(td)
      row = @presenter.detail_row(p, i)
      assert_equal(p.pro_rata_days, row[28])
    end
  end

  def test_detail_records_have_correct_temporary_cessation_value
    @presenter.transaction_details.each_with_index do |td, i|
      td.temporary_cessation = i.odd?
      expected_value = i.odd? ? '50%' : ''

      p = CfdTransactionDetailPresenter.new(td)
      row = @presenter.detail_row(p, i)
      assert_equal expected_value, row[32]
    end
  end

  def test_detail_record_has_correct_transaction_date
    expected_value = @file.generated_at.strftime("%d-%^b-%Y") # DD-MMM-YYYY format
    @presenter.transaction_details.each_with_index do |td, i|
      p = CfdTransactionDetailPresenter.new(td)
      row = @presenter.detail_row(p, i)
      assert_equal expected_value, row[3]
      assert_equal expected_value, row[9]
    end
  end

  def test_detail_record_variation_is_blank_when_100_percent
    @presenter.transaction_details.each_with_index do |td, i|
      p = CfdTransactionDetailPresenter.new(td)
      if i.odd?
        p.line_attr_9 = '100%'
        p.variation = nil
      else
        p.variation = '100%'
      end
      row = @presenter.detail_row(p, i)
      assert row[31].blank?
    end
  end

  def test_detail_record_consent_number_not_prefixed
    # consent no. shouldn't be prefixed with 'Consent No - ' or 
    # 'Authorization No ' as per the incoming file value
    @presenter.transaction_details.each_with_index do |td, i|
      expected_value = td.reference_1
      p = CfdTransactionDetailPresenter.new(td)
      row = @presenter.detail_row(p, i)
      assert_equal expected_value, row[25]
    end
  end

  def test_is_returns_a_trailer_record
    count = @presenter.transaction_details.count
    assert_equal(
      [
        "T",
        (count + 1).to_s.rjust(7, '0'),
        (count + 2).to_s.rjust(7, '0'),
        @presenter.transaction_details.where(tcm_transaction_type: 'I').sum(:tcm_charge).to_i,
        @presenter.transaction_details.where(tcm_transaction_type: 'C').sum(:tcm_charge).to_i
      ],
      @presenter.trailer
    )
  end

  def set_charge_calculation(transaction)
    transaction.charge_calculation = {
      'calculation' => {
        'chargeAmount' => transaction.tcm_charge.abs,
        'decisionPoints' => {
          'baselineCharge' => 196803,
          'percentageAdjustment' => 0
        }
      },
      'generatedAt' => '10-AUG-2017'
    }
    transaction.save
  end
end

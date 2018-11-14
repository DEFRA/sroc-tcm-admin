require 'test_helper.rb'

class PermitCategoryProcessorTest < ActiveSupport::TestCase
  include ChargeCalculation
  def setup
    @header = transaction_headers(:cfd_annual)
    fixup_transactions(@header)
 
    @user = User.system_account
    Thread.current[:current_user] = @user

    @processor = PermitCategoryProcessor.new(@header)
    @calculator = build_mock_calculator
    @processor.stubs(:calculator).returns(@calculator)
    @header.regime.permit_categories.create!(code: '2.3.5',
                                             description: 'test',
                                             status: 'active')
  end

  def test_fetch_unique_consents_returns_list_of_consent_references
    consents = @header.transaction_details.pluck(:reference_1).uniq.sort
    assert_equal consents, @processor.fetch_unique_consents
  end

  def test_only_invoices_in_file_returns_true_when_only_invoices_in_file_for_consent
    assert @processor.only_invoices_in_file? 'AAAA/1/1'
  end

  def test_only_invoices_in_file_returns_false_when_credits_in_file_for_consent
   refute @processor.only_invoices_in_file? 'AAAF/2/3'
  end

  def test_find_historic_transactions_returns_nil_when_no_matches_found
    assert_nil @processor.find_historic_transaction('AAAB/1/1')
  end

  def test_find_historic_transaction_returns_newest_matching_transaction
    # newest == newest period_end date
    historic = generate_historic
    assert_equal historic[1], @processor.find_historic_transaction('AAAA/1/1')
  end

  def test_set_category_sets_category
    transaction = @header.transaction_details.
      find_by(reference_1: 'AAAA/1/1')
    @processor.set_category(transaction, '2.3.4')
    assert_equal '2.3.4', transaction.reload.category
    assert_equal 'Assigned matching category', transaction.category_logic
  end

  def test_set_category_does_not_set_category_when_category_removed
    transaction = @header.transaction_details.
      find_by(reference_1: 'AAAA/1/1')
    @processor.set_category(transaction, '2.3.9')
    assert_nil transaction.reload.category
    assert_equal 'Category not valid for financial year',
      transaction.category_logic
  end

  def test_set_category_does_not_set_category_if_calculation_error
    @calculator = build_mock_calculator_with_error
    @processor.stubs(:calculator).returns(@calculator)

    transaction = @header.transaction_details.
      find_by(reference_1: 'AAAA/1/1')
    @processor.set_category(transaction, '2.3.4')
    assert_nil transaction.reload.category
    assert_equal 'Error assigning charge', transaction.category_logic
  end

  def test_suggest_categories_processes_transactions_in_file
    history = generate_historic
    @processor.suggest_categories

    [
      [ 'ANQA/1234/1/2', nil, 'No previous bill found' ],
      [ 'AAAA/1/1', '2.3.5', 'Assigned matching category' ],
      [ 'AAAB/1/1', nil, 'No previous bill found' ],
      [ 'AAAC/1/1', nil, 'No previous bill found' ],
      [ 'AAAD/1/1', nil, 'No previous bill found' ],
      [ 'AAAE/1/1', nil, 'No previous bill found' ],
      [ 'AAAE/1/2', nil, 'No previous bill found' ],
      [ 'AAAF/2/3', nil, 'Not part of an annual bill' ]
    ].each do |td|
      t = @header.transaction_details.find_by(reference_1: td[0])
      if td[1].nil?
        assert_nil t.category, "Failed category #{td[0]}"
      else
        assert_equal td[1], t.category, "Failed category #{td[0]}"
      end
      assert_equal td[2], t.category_logic, "Failed logic #{td[0]}"
    end
  end

  def test_suggest_categories_generates_audit_records
    history = generate_historic
    assert_difference 'AuditLog.count', 9 do
      @processor.suggest_categories
    end
  end

  def generate_historic
    t = transaction_details(:cfd)
    history = []
    tt = t.dup
    tt.reference_1 = 'AAAA/1/1'
    tt.reference_2 = '1' 
    tt.reference_3 = '1'
    tt.customer_reference = 'A1234'
    tt.status = 'billed'
    tt.line_amount = 12567
    tt.category = '2.3.4'
    tt.period_start = '1-APR-18'
    tt.period_end = '31-MAR-19'
    tt.tcm_financial_year = '1819'
    tt.save!
    history << tt
    ttt = tt.dup
    ttt.line_amount = 32411
    ttt.category = '2.3.5'
    ttt.period_start = '1-APR-19'
    ttt.period_end = '31-MAR-20'
    ttt.tcm_financial_year = '1920'
    ttt.save!
    history << ttt
    history
  end

  def fixup_transactions(header)
    t = transaction_details(:cfd_annual)
    [
      ["AAAA", "1", "1", 12345, "A1234"],
      ["AAAB", "1", "1", 67890, "A3453"],
      ["AAAC", "1", "1", 12233, "A9483"],
      ["AAAD", "1", "1", 22991, "A33133"],
      ["AAAE", "1", "1", 435564, "A938392"],
      ["AAAE", "1", "2", 23665, "A938392"],
      ["AAAF", "2", "3", 124322, "A993022"],
      ["AAAF", "2", "3", -123991, "A993022"]
    ].each_with_index do |ref, i|
      tt = t.dup
      tt.sequence_number = 2 + i
      tt.reference_1 = ref[0..2].join('/')
      tt.reference_2 = ref[1]
      tt.reference_3 = ref[2]
      tt.line_amount = ref[3]
      tt.customer_reference = ref[4]
      tt.transaction_header_id = header.id
      tt.period_start = '1-APR-19'
      tt.period_end = '31-MAR-20'
      tt.tcm_financial_year = '1920'
      tt.save!
    end
  end
end

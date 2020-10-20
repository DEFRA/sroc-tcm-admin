# frozen_string_literal: true

require "test_helper.rb"

class CfdTransactionDetailPresenterTest < ActiveSupport::TestCase
  def setup
    @transaction = transaction_details(:cfd)
    @presenter = CfdTransactionDetailPresenter.new(@transaction)
  end

  def test_it_returns_charge_params
    assert_equal(
      {
        permitCategoryRef: @transaction.category,
        percentageAdjustment: clean_variation,
        temporaryCessation: @presenter.temporary_cessation,
        compliancePerformanceBand: "B",
        billableDays: billable_days,
        financialDays: financial_year_days,
        chargePeriod: charge_period,
        preConstruction: false,
        environmentFlag: "TEST"
      },
      @presenter.charge_params
    )
  end

  def test_it_returns_discharge_description
    assert_equal(@presenter.discharge_description, @transaction.line_attr_2)
  end

  def test_it_returns_site
    assert_equal(@presenter.site, @transaction.line_attr_1)
  end

  def test_pro_rata_days_is_correctly_formatted
    days = @presenter.line_attr_4.split("/")
    assert_equal("#{days[1]}/#{days[0]}", @presenter.pro_rata_days)
  end

  def test_pro_rata_days_returns_empty_when_full_year
    @transaction.period_start = Time.zone.parse("1-APR-2018 00:00:00")
    @transaction.period_end = Time.zone.parse("31-MAR-2019 23:59:59")
    assert_empty(@presenter.pro_rata_days)
  end

  def test_it_returns_billable_days
    assert_equal(@presenter.billable_days, billable_days)
  end

  def test_billable_days_match_line_attr_4_part
    days = @presenter.line_attr_4.split("/")
    assert_equal(days[1].to_i, @presenter.billable_days)
  end

  def test_it_returns_financial_year_days
    assert_equal(@presenter.financial_year_days, financial_year_days)
  end

  def test_financial_year_days_match_line_attr_4_part
    days = @presenter.line_attr_4.split("/")
    assert_equal(days[0].to_i, @presenter.financial_year_days)
  end

  def test_it_returns_financial_year
    assert_equal(@presenter.financial_year, financial_year)
  end

  def test_it_returns_charge_period
    assert_equal(@presenter.charge_period, charge_period)
  end

  def test_it_returns_clean_variation_percentage
    assert_equal(@presenter.clean_variation_percentage, clean_variation)
  end

  def test_variation_percentage_file_returns_blank_when_100
    @presenter.variation = "100%"
    assert_equal("", @presenter.variation_percentage_file)
  end

  def test_it_returns_consent_reference
    assert_equal(@presenter.consent_reference, @transaction.reference_1)
  end

  def test_it_returns_permit_reference
    assert_equal(@presenter.permit_reference, @transaction.reference_1)
  end

  def test_it_returns_a_version
    assert_equal(@presenter.version, @transaction.reference_2)
  end

  def test_it_returns_a_discharge_reference
    assert_equal(@presenter.discharge_reference, @transaction.reference_3)
  end

  def test_temporary_cessation_flag_returns_Y_when_true
    @presenter.temporary_cessation = true
    assert_equal("Y", @presenter.temporary_cessation_flag)
  end

  def test_temporary_cessation_flag_returns_N_when_false
    @presenter.temporary_cessation = false
    assert_equal("N", @presenter.temporary_cessation_flag)
  end

  def test_temporary_cessation_file_returns_50_percent_or_blank
    @presenter.temporary_cessation = true
    assert_equal("50%", @presenter.temporary_cessation_file)
    @presenter.temporary_cessation = false
    assert_equal("", @presenter.temporary_cessation_file)
  end

  def test_discharge_location_has_correct_prefix
    val = "Discharge Location: #{@transaction.line_attr_1}"
    assert_equal(val, @presenter.discharge_location)
  end

  def test_discharge_location_has_prefix_when_blank
    @presenter.line_attr_1 = nil
    assert_equal("Discharge Location: ", @presenter.discharge_location)
  end

  def test_pre_sroc_flag_returns_Y_for_retrospective_transactions
    @transaction.status = "retrospective"
    assert_equal "Y", @presenter.pre_sroc_flag, "Pre-SRoC flag incorrect"
  end

  def test_pre_sroc_flag_returns_Y_for_retro_billed_transactions
    @transaction.status = "retro_billed"
    assert_equal "Y", @presenter.pre_sroc_flag, "Pre-SRoC flag incorrect"
  end

  def test_tcm_compliance_percentage_is_always_blank
    ["A(100%)", "B (87%)", "()"].each do |cp|
      @transaction.charge_calculation = build_compliance(cp)
      v = @presenter.tcm_compliance_percentage
      assert v.blank?, "Compliance percentage not blank: '#{v}'"
    end
  end

  def test_it_transforms_into_json
    assert_equal({
                   id: @transaction.id,
      customer_reference: @presenter.customer_reference,
      tcm_transaction_reference: @presenter.tcm_transaction_reference,
      generated_filename: @presenter.generated_filename,
      generated_file_date: @presenter.generated_file_date,
      original_filename: @presenter.original_filename,
      original_file_date: @presenter.original_file_date_table,
      consent_reference: @presenter.consent_reference,
      version: @presenter.version,
      discharge: @presenter.discharge_reference,
      sroc_category: @presenter.category,
      confidence_level: @presenter.confidence_level,
      category_locked: @presenter.category_locked,
      can_update_category: @presenter.can_update_category?,
      variation: @presenter.clean_variation_percentage,
      temporary_cessation: @presenter.temporary_cessation_flag,
      tcm_financial_year: @presenter.tcm_financial_year,
      financial_year: @presenter.charge_period,
      region: @presenter.region,
      period: @presenter.period,
      line_amount: @presenter.original_charge,
      amount: @presenter.amount,
      excluded: @presenter.excluded,
      excluded_reason: @presenter.excluded_reason,
      error_message: @presenter.error_message
                 }, @presenter.as_json)
  end

  def clean_variation
    v = @transaction.variation
    return 100 if v.blank?

    v.gsub(/%/, "")
  end

  def financial_year_days
    year = financial_year
    start_date = Date.new(year, 4, 1) # 1st April
    end_date = Date.new(year + 1, 3, 31) # 31st March
    (end_date - start_date).to_i + 1
  end

  def billable_days
    (@transaction.period_end.to_date - @transaction.period_start.to_date).to_i + 1
  end

  def financial_year
    @transaction.period_start.month < 4 ? @transaction.period_start.year + 1 : @transaction.period_start.year
  end

  def charge_period
    "FY#{@transaction.tcm_financial_year}"
  end

  def build_compliance(val)
    {
      "calculation" => {
        "compliancePerformanceBand" => val
      }
    }
  end
end

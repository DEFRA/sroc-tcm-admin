class PasTransactionDetailPresenter < TransactionDetailPresenter
  def charge_params
    {
      permitCategoryRef: category,
      temporaryCessation: temporary_cessation,
      compliancePerformanceBand: compliance_band,
      billableDays: billable_days,
      financialDays: financial_year_days,
      chargePeriod: charge_period,
      preConstruction: false,
      environmentFlag: 'TEST'
    }
  end

  def compliance_band
    band = line_attr_11.first if line_attr_11.present?
    band || ""
  end

  def percentage_adjustment
    # FIXME: this is wrong - this is not a percentage value
    # charge calculation adjustment as a percentage - ie. 95%
    val = charge_calculation['calculation']['decisionPoints']['percentageAdjustment']
    "#{val}%"
  end

  def permit_reference
    reference_1
  end

  def original_permit_reference
    reference_2
  end

  def site
    header_attr_3
  end

  def site_address
    @site_address ||= make_site_address
  end

  def make_site_address
    cols = [ :header_attr_2,
             :header_attr_3,
             :header_attr_4,
             :header_attr_5,
             :header_attr_6,
             :header_attr_7,
             :header_attr_8 ]

    parts = cols.map { |c| value_or_space(c) }
    first = parts.shift
    first += ':' unless first.ends_with?(':')
    addr = first + ' ' + parts.shift + ','
    addr += parts.join(',')
    addr
  end

  def value_or_space(attr)
    val = transaction_detail.send(attr.to_sym)
    if val.blank?
      " "
    else
      val
    end
  end

  def as_json(options = {})
    {
      id: id,
      customer_reference: customer_reference,
      tcm_transaction_reference: tcm_transaction_reference,
      generated_filename: generated_filename,
      original_filename: original_filename,
      original_file_date: original_file_date_table,
      permit_reference: permit_reference,
      original_permit_reference: original_permit_reference,
      compliance_band: compliance_band,
      site: site,
      sroc_category: category,
      temporary_cessation: temporary_cessation_flag,
      financial_year: charge_period,
      region: region_from_ref,
      period: period,
      line_amount: original_charge,
      amount: amount,
      error_message: error_message
    }
  end
end

class TransactionDetailPresenter < SimpleDelegator

  def self.wrap(collection)
    collection.map { |o| new o }
  end

  def file_reference
    transaction_detail.transaction_header.file_reference
  end

  def permit_reference
    "todo"
  end

  def sroc_category
    case category
    when '1'
      'Category 1'
    when '2'
      'Category 2'
    else
      ''
    end
  end

  def compliance_band
    "todo"
  end

  def billable_days
    (period_end.to_date - period_start.to_date).to_i + 1
  end

  def financial_year_days
    year = financial_year
    start_date = Date.new(year, 4, 1)
    end_date = Date.new(year + 1, 3, 31)
    (end_date - start_date).to_i + 1
  end

  def financial_year
    period_start.month < 4 ? period_start.year - 1 : period_start.year
  end

  def charge_period
    year = financial_year - 2000
    "FY#{year}#{year + 1}"
  end

  def credit_debit_indicator
    line_amount < 0 ? 'C' : 'D'
  end

  def date_received
    fmt_date created_at
  end

  def temporary_cessation_flag
    temporary_cessation? ? 'Y' : 'N'
  end

  def period
    "#{period_start.strftime("%d/%m/%y")} - #{period_end.strftime("%d/%m/%y")}"
  end

  def amount
    if transaction_detail.charge_calculated?
      value = charge_amount
      if value.nil?
        credit_debit
      else
        ActiveSupport::NumberHelper.number_to_currency(
          sprintf('%.2f', value), unit: "")
      end
    else
      credit_debit
    end
  end

  def credit_debit
    if line_amount.negative?
      'Credit (TBC)'
    else
      'Invoice (TBC)'
    end
  end

  def charge_amount
    charge = transaction_detail.charge_calculation
    if charge && charge["calculation"] && charge["calculation"]["messages"].nil?
      amt = charge["calculation"]["chargeValue"]
      # FIXME: is this the /best/ way to determine a credt?
      amt *= -1 if !amt.nil? && line_amount.negative?
      amt
    else
      nil
    end
  end

  def generated_at
    # TODO: replace this with the date *we* generated the file
    fmt_date transaction_detail.transaction_header.generated_at
  end

private
  def transaction_detail
    __getobj__
  end

  def padded_number(val, length = 7)
    val.to_s.rjust(length, "0")
  end

  def fmt_date(dt)
    dt.strftime("%-d-%^b-%Y")
  end
end

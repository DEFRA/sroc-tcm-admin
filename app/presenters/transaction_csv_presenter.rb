class TransactionCsvPresenter < SimpleDelegator
  def header
    [
      "H",
      padded_number(0),
      feeder_source_code,
      region,
      "I",
      file_id,
      bill_run_id,
      fmt_date(generated_at)
    ]
  end

  def details
    records = []
    transaction_details.order(:sequence_number).each do |td|
      records << [
        "D",
        padded_number(td.sequence_number),
        td.customer_reference,
        fmt_date(td.transaction_date),
        td.transaction_type,
        td.transaction_reference,
        td.related_reference,
        td.currency_code,
        td.header_narrative,
        td.header_attr_1,
        td.header_attr_2,
        td.header_attr_3,
        td.header_attr_4,
        td.header_attr_5,
        td.header_attr_6,
        td.header_attr_7,
        td.header_attr_8,
        td.header_attr_9,
        td.header_attr_10,
        padded_number(td.line_amount, 3),
        td.line_vat_code,
        td.line_area_code,
        td.line_description,
        td.line_income_stream_code,
        td.line_context_code,
        td.line_attr_1,
        td.line_attr_2,
        td.line_attr_3,
        td.line_attr_4,
        td.line_attr_5,
        td.line_attr_6,
        td.line_attr_7,
        td.line_attr_8,
        td.line_attr_9,
        td.line_attr_10,
        td.line_attr_11,
        td.line_attr_12,
        td.line_attr_13,
        td.line_attr_14,
        td.line_attr_15,
        td.line_quantity,
        td.unit_of_measure,
        padded_number(td.unit_of_measure_price, 3)
      ]
    end
    records
  end

  def trailer
    count = transaction_details.count
    [
      "T",
      padded_number(count + 1),
      padded_number(count + 2, 8),
      invoice_total,
      credit_total
    ]
  end

private
  def transaction_header
    __getobj__
  end

  def padded_number(val, length = 7)
    val.to_s.rjust(length, "0")
  end

  def file_id
    file_sequence_number.to_s.rjust(5, "0")
  end

  def fmt_date(dt)
    dt.strftime("%-d-%^b-%Y")
  end
end

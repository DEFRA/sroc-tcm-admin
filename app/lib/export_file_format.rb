# frozen_string_literal: true

module ExportFileFormat
  EXPORT_COLUMNS = [
    { heading: "Customer Reference", accessor: :customer_reference },
    { heading: "Transaction Date", accessor: :original_transaction_date },
    { heading: "Transaction Type", accessor: :transaction_type },
    { heading: "Transaction Reference", accessor: :transaction_reference },
    { heading: "Related Reference", accessor: :related_reference },
    { heading: "Currency Code", accessor: :currency_code },
    { heading: "Header Narrative", accessor: :header_narrative },
    { heading: "Header Attr 1", accessor: :header_attr_1 },
    { heading: "Header Attr 2", accessor: :header_attr_2 },
    { heading: "Header Attr 3", accessor: :header_attr_3 },
    { heading: "Header Attr 4", accessor: :header_attr_4 },
    { heading: "Header Attr 5", accessor: :header_attr_5 },
    { heading: "Header Attr 6", accessor: :header_attr_6 },
    { heading: "Header Attr 7", accessor: :header_attr_7 },
    { heading: "Header Attr 8", accessor: :header_attr_8 },
    { heading: "Header Attr 9", accessor: :header_attr_9 },
    { heading: "Header Attr 10", accessor: :header_attr_10 },
    { heading: "Currency Line Amount", accessor: :currency_line_amount },
    { heading: "Line VAT Code", accessor: :line_vat_code },
    { heading: "Line Area Code", accessor: :line_area_code },
    { heading: "Line Description", accessor: :line_description },
    { heading: "Line Income Stream Code", accessor: :line_income_stream_code },
    { heading: "Line Context Code", accessor: :line_context_code },
    { heading: "Line Attr 1", accessor: :line_attr_1 },
    { heading: "Line Attr 2", accessor: :line_attr_2 },
    { heading: "Line Attr 3", accessor: :line_attr_3 },
    { heading: "Line Attr 4", accessor: :line_attr_4 },
    { heading: "Line Attr 5", accessor: :line_attr_5 },
    { heading: "Line Attr 6", accessor: :line_attr_6 },
    { heading: "Line Attr 7", accessor: :line_attr_7 },
    { heading: "Line Attr 8", accessor: :line_attr_8 },
    { heading: "Line Attr 9", accessor: :line_attr_9 },
    { heading: "Line Attr 10", accessor: :line_attr_10 },
    { heading: "Line Attr 11", accessor: :line_attr_11 },
    { heading: "Line Attr 12", accessor: :line_attr_12 },
    { heading: "Line Attr 13", accessor: :line_attr_13 },
    { heading: "Line Attr 14", accessor: :line_attr_14 },
    { heading: "Line Attr 15", accessor: :line_attr_15 },
    { heading: "Line Quantity", accessor: :line_quantity },
    { heading: "Unit Of Measure", accessor: :unit_of_measure },
    { heading: "Currency Unit Of Measure Price", accessor: :currency_unit_of_measure_price },
    { heading: "Reference 1", accessor: :reference_1 },
    { heading: "Reference 2", accessor: :reference_2 },
    { heading: "Reference 3", accessor: :reference_3 },
    { heading: "Customer Name", accessor: :customer_name },
    { heading: "Variation", accessor: :variation },
    { heading: "Temporary Cessation Flag", accessor: :temporary_cessation_flag },
    { heading: "Category", accessor: :category },
    { heading: "Category Description", accessor: :category_description },
    { heading: "Period Start", accessor: :period_start },
    { heading: "Period End", accessor: :period_end },
    { heading: "TCM Financial Year", accessor: :tcm_financial_year },
    { heading: "Original Filename", accessor: :original_filename },
    { heading: "Original File Date", accessor: :original_file_date },
    { heading: "Pro Rata Days", accessor: :pro_rata_days },
    { heading: "Currency Baseline Charge", accessor: :currency_baseline_charge },
    { heading: "Currency TCM Charge", accessor: :currency_tcm_charge },
    { heading: "Generated Filename", accessor: :generated_filename },
    { heading: "Generated File Date", accessor: :generated_file_date },
    { heading: "TCM Transaction Type", accessor: :tcm_transaction_type },
    { heading: "TCM Transaction Reference", accessor: :tcm_transaction_reference },
    { heading: "Region", accessor: :region },
    { heading: "Transaction Status", accessor: :status },
    { heading: "Pre-SRoC", accessor: :pre_sroc_flag },
    { heading: "Excluded", accessor: :excluded_flag },
    { heading: "Exclusion Reason", accessor: :excluded_reason },
    { heading: "Suggested Category", accessor: :suggested_category_code },
    { heading: "Confidence Level", accessor: :suggested_category_confidence_level },
    { heading: "Suggestion Overridden", accessor: :suggested_category_overridden_flag },
    { heading: "Override Lock", accessor: :suggested_category_admin_lock_flag },
    { heading: "Assignment Outcome", accessor: :suggested_category_logic },
    { heading: "Suggestion Stage", accessor: :suggested_category_stage },
    { heading: "Checked Flag", accessor: :approved_flag },
    { heading: "Checked Date", accessor: :approved_date },
    { heading: "TCM Compliance %", accessor: :tcm_compliance_percentage }
  ].freeze

  COLUMNS = %i[
    customer_reference
    transaction_date
    transaction_type
    transaction_reference
    related_reference
    currency_code
    header_narrative
    header_attr_1
    header_attr_2
    header_attr_3
    header_attr_4
    header_attr_5
    header_attr_6
    header_attr_7
    header_attr_8
    header_attr_9
    header_attr_10
    currency_line_amount
    line_vat_code
    line_area_code
    line_description
    line_income_stream_code
    line_context_code
    line_attr_1
    line_attr_2
    line_attr_3
    line_attr_4
    line_attr_5
    line_attr_6
    line_attr_7
    line_attr_8
    line_attr_9
    line_attr_10
    line_attr_11
    line_attr_12
    line_attr_13
    line_attr_14
    line_attr_15
    line_quantity
    unit_of_measure
    currency_unit_of_measure_price
    reference_1
    reference_2
    reference_3
    variation
    temporary_cessation_flag
    category
    category_description
    period_start
    period_end
    tcm_financial_year
    original_filename
    original_file_date
    pro_rata_days
    currency_baseline_charge
    currency_tcm_charge
  ].freeze

  HISTORY_COLUMNS = COLUMNS + %i[
    generated_filename
    tcm_file_date
    tcm_transaction_type
    tcm_transaction_reference
  ].freeze
end

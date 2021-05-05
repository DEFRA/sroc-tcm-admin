# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_detail do
    sequence_number { 1 }
    customer_reference { "A1234B" }
    transaction_date { 2.months.ago }
    transaction_type { "I" }
    status { "unbilled" }
    transaction_reference { rand(36**8).to_s(36).upcase }
    currency_code { "GBP" }
    header_attr_1 { 2.months.ago.strftime("%d-%^b-%Y") }
    line_amount { 23747 }
    line_description { "Consent No - TONY/1234/1/1" }
    line_area_code { "3" }
    line_income_stream_code { "C" }
    line_context_code { "D" }
    line_attr_1 { "Green Rd. Pig Disposal" }
    line_attr_2 { "STORM SEWAGE OVERFLOW" }
    line_attr_3 { "01/04/17 - 10/08/17" }
    line_attr_4 { "365/132" }
    line_attr_5 { "C 1" }
    line_attr_6 { "E 1" }
    line_attr_7 { "S 1" }
    line_attr_8 { "684" }
    line_attr_9 { "96%" }
    line_quantity { 1 }
    reference_1 { "TONY/1234/1/1" }
    reference_2 { "1" }
    reference_3 { "1" }
    unit_of_measure { "Each" }
    unit_of_measure_price { 23747 }
    period_start { "01-Apr-2017" }
    period_end { "10-Aug-2017" }
    original_filename { "CFDBI00123" }
    original_file_date { 2.weeks.ago.to_date }
    tcm_financial_year { "1718" }
    region { 'A' }

    association :transaction_header, factory: :transaction_header
  end
end

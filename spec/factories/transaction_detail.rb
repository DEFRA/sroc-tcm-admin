# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_detail do
    sequence_number { 1 }
    customer_reference { "A1234B" }
    transaction_date { Date.new(2021, 8, 13) }
    transaction_type { "I" }
    status { "unbilled" }
    transaction_reference { rand(36**8).to_s(36).upcase }
    currency_code { "GBP" }
    header_attr_1 { "13-AUG-2021" }
    line_amount { 23_747 }
    line_description { "Consent No - TONY/1234/1/1" }
    line_area_code { "3" }
    line_income_stream_code { "C" }
    line_context_code { "D" }
    line_quantity { 1 }
    unit_of_measure { "Each" }
    unit_of_measure_price { 23_747 }
    period_start { "01-Apr-2017" }
    period_end { "10-Aug-2017" }
    original_file_date { Date.new(2021, 9, 29) }
    tcm_financial_year { "2021" }
    region { "A" }
    tcm_charge { 23_747 }

    trait :cfd do
      line_attr_1 { "Green Rd. Pig Disposal" }
      line_attr_2 { "STORM SEWAGE OVERFLOW" }
      line_attr_3 { "01/04/17 - 10/08/17" }
      line_attr_4 { "365/132" }
      line_attr_5 { "C 1" }
      line_attr_6 { "E 1" }
      line_attr_7 { "S 1" }
      line_attr_8 { "684" }
      line_attr_9 { "96%" }
      reference_1 { "TONY/1234/1/1" }
      reference_2 { "1" }
      reference_3 { "1" }
      original_filename { "CFDBI00123" }
    end

    trait :pas do
      header_attr_2 { "Site" }
      header_attr_3 { "Red St. Hill Farm" }
      header_attr_8 { "AB12 1AB" }
      line_attr_1 { "" }
      line_attr_2 { "" }
      line_attr_3 { "" }
      line_attr_4 { "" }
      line_attr_5 { "" }
      line_attr_6 { "" }
      line_attr_7 { "" }
      line_attr_8 { "" }
      line_attr_9 { "" }
      line_attr_11 { "F 3.0" }
      line_attr_15 { "Directly Associated Activity only" }
      reference_1 { "VP3839DA" }
      reference_2 { "ABC1234A" }
      reference_3 { "ZZ1234ZZ" }
      filename { "PASYI00337.dat.transfered-19062017" }
      original_filename { "PASYI00337" }
    end

    trait :wml do
      header_attr_10 { "From 06/03/2018" }
      line_description { "In cancellation of invoice no. E01181293: Credit of subsistence charge due to the licence being surrendered.wef 6/3/2018 at Hairy Wigwam, Big Pig Farm, Great Upperford, Big Town, BT5 5EL, Permit Ref: XZ3333PG/A001" }
      line_attr_1 { "" }
      line_attr_2 { "026101" }
      line_attr_3 { "From 6th March 2018 (26 Days)" }
      line_attr_4 { "" }
      line_attr_5 { "" }
      line_attr_6 { "" }
      line_attr_7 { "" }
      line_attr_8 { "" }
      line_attr_9 { "" }
      reference_1 { "026101" }
      reference_2 { "XZ3333PG/A001" }
      reference_3 { "1" }
      category { "2.15.2" }
      original_filename { "WMLEI07892" }
    end

    trait :approved do
      approved_for_billing { true }
      approved_for_billing_at { 2.months.ago }
    end

    association :transaction_header, factory: :transaction_header
  end
end

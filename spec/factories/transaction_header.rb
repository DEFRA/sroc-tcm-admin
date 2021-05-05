# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_header do
    feeder_source_code { "CFD" }
    region { "A" }
    file_type_flag { "I" }
    file_sequence_number { 371 }
    generated_at { 2.months.ago.to_date }
    transaction_count { 1 }
    invoice_total { 0 }
    credit_total { 0 }

    association :regime, factory: :regime
  end
end

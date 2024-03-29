# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_header do
    feeder_source_code { "CFD" }
    region { "A" }
    file_type_flag { "I" }
    file_sequence_number { 371 }
    generated_at { Date.new(2021, 8, 13) }
    transaction_count { 1 }
    invoice_total { 0 }
    credit_total { 0 }

    trait :pas do
      feeder_source_code { "PAS" }
    end

    trait :wml do
      feeder_source_code { "WML" }
    end

    trait :removed do
      removed { true }
      removal_reference { rand(36**8).to_s(36).upcase }
      removal_reason { "Removed for test purposes" }
      removed_at { Date.new(2021, 8, 13) }
    end

    association :regime, factory: :regime
  end
end

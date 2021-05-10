# frozen_string_literal: true

FactoryBot.define do
  factory :sequence_counter do
    region { "A" }
    file_number { 50_001 }
    invoice_number { 1 }

    association :regime
  end
end

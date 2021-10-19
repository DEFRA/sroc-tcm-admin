# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_file do
    region { "A" }
    state { "initialised" }
    generated_at { Date.new(2021, 9, 29) }
  end
end

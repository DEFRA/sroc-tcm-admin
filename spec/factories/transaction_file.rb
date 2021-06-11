# frozen_string_literal: true

FactoryBot.define do
  factory :transaction_file do
    region { "A" }
    state { "initialised" }
  end
end

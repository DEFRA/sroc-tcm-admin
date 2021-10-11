# frozen_string_literal: true

FactoryBot.define do
  factory :permit_category do
    code { "2.3.4" }
    description { "Sewage 50,000 - 150,000 m3/day" }
    status { "active" }
    valid_from { "1819" }
  end
end

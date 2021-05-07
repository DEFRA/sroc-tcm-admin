# frozen_string_literal: true

FactoryBot.define do
  factory :regime do
    name { "CFD" }
    slug { "cfd" }
    title { "Water Quality" }

    export_data_file { association :export_data_file, regime: instance }

    trait :pas do
      name { "PAS" }
      slug { "pas" }
      title { "Installations" }
    end

    trait :wml do
      name { "WML" }
      slug { "wml" }
      title { "Waste" }
    end
  end
end

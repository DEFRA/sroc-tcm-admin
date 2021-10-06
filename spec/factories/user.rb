# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "system@example.com" }
    first_name { "System" }
    last_name { "Account" }
    role { "admin" }
    password { "Secret123" }

    trait :admin do
      email { "admin@sroc.gov.uk" }
      first_name { "Admin" }
      last_name { "User" }
      role { "admin" }
    end

    trait :billing do
      email { "billing@sroc.gov.uk" }
      first_name { "Billing" }
      last_name { "User" }
      role { "billing" }
    end

    trait :read_only do
      email { "readonly@sroc.gov.uk" }
      first_name { "Readonly" }
      last_name { "User" }
      role { "read_only" }
    end

    trait :read_only_export do
      email { "readonlyexport@sroc.gov.uk" }
      first_name { "Readonlyexport" }
      last_name { "User" }
      role { "read_only_export" }
    end

    factory :user_with_regime do
      transient do
        regime { create(:regime) }
      end

      after(:build) do |user, evaluator|
        user.regime_users.build(regime_id: evaluator.regime.id, enabled: true)
      end
    end
  end
end

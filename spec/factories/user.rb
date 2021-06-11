# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { "system@example.com" }
    first_name { "System" }
    last_name { "Account" }
    role { "admin" }
    password { "Secret123" }

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

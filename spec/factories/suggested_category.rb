# frozen_string_literal: true

FactoryBot.define do
  factory :suggested_category do
    confidence_level { 2 }
    admin_lock { false }
    overridden { false }
    suggestion_stage { "Annual billing - stage 2" }
    logic { "No previous bill found" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :campaign_recipient do
    association :commune
    association :campaign
    current_step { nil }

    trait :step_lancement do
      current_step { "lancement" }
      # TODO: association campaign email
    end
  end
end

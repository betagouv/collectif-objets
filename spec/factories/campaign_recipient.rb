# frozen_string_literal: true

FactoryBot.define do
  factory :campaign_recipient do
    commune { association(:commune_with_user) }
    association :campaign
    current_step { nil }
    sequence(:unsubscribe_token) { |n| 3_454_234 + n }

    trait :step_lancement do
      current_step { "lancement" }
      # TODO: association campaign email
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :recenseur_access do
    recenseur
    commune

    trait :newly_granted do
      granted { true }
      notified { false }
    end
  end
end

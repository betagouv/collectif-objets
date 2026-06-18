# frozen_string_literal: true

FactoryBot.define do
  factory :recenseur_access do
    recenseur
    commune

    trait :newly_granted do
      granted { true }
      notified { false }
    end

    trait :newly_revoked do
      granted { false }
      notified { false }
    end
  end
end

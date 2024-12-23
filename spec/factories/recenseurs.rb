# frozen_string_literal: true

FactoryBot.define do
  factory :recenseur do
    transient do
      communes { [] }
    end
    sequence(:email) { |n| "recenseur-#{n}@mairie-tests.fr" }

    after(:build) do |recenseur, evaluator|
      evaluator.communes.each do |commune|
        recenseur.accesses.build(commune:, granted: true)
      end
    end
  end
end

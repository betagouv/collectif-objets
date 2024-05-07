# frozen_string_literal: true

FactoryBot.define do
  factory :dossier do
    association :commune

    trait :submitted do
      status { "submitted" }
      notes_commune { "Voici les recensements demandés" }
      submitted_at { 2.days.ago }
    end

    trait :accepted do
      status { "accepted" }
      accepted_at { 2.days.ago }
      notes_conservateur { "Quels beaux tableaux" }
    end
  end
end

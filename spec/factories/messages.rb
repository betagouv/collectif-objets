# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    commune
    author factory: %i[user]
    origin { "web" }
    text { "Comment s'appelle l'objet en question ?\nJe ne le trouve pas" }
    automated_mail_name { nil }
    created_at { 1.day.ago }

    trait :from_commune do
      author { commune.users.first }
    end
  end
end

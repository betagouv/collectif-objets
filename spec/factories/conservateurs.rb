# frozen_string_literal: true

FactoryBot.define do
  factory :conservateur do
    sequence(:email) { |n| "user-#{n + 1}@culture.gouv.fr" }
  end
end

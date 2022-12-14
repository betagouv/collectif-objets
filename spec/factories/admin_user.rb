# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "user-#{n + 1}@beta.gouv.fr" }
  end
end

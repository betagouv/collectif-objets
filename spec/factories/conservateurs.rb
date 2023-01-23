# frozen_string_literal: true

FactoryBot.define do
  factory :conservateur do
    sequence(:email) { |n| "user-#{n + 1}@culture.gouv.fr" }
    password { "super-long-mot-de-passe-tres-securise" }
    first_name { "Jeanne" }
    last_name { "Cevenole" }
    reset_password_token { "" }
    reset_password_sent_at { nil }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :admin_user do
    sequence(:email) { |n| "user-#{n + 1}@beta.gouv.fr" }
    first_name { "Jeanne" }
    last_name { "Turbo" }
    password { "password" }
    otp_required_for_login { true }
    otp_secret { AdminUser.generate_otp_secret }
  end
end

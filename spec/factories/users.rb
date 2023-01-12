# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n + 1}@mairie-tests.fr" }
    role { "mairie" }
    sequence(:magic_token) { |n| "#{n}-#{SecureRandom.hex(5)}" }
  end
end

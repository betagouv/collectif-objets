# frozen_string_literal: true

FactoryBot.define do
  factory :session_code do
    record { association :user }
    sequence(:code) { |n| (234_533 + n).to_s }
    created_at { 2.minutes.ago }
  end
end

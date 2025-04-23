# frozen_string_literal: true

FactoryBot.define do
  factory :recenseur do
    sequence(:email) { |n| "recenseur-#{n}@mairie-tests.fr" }
  end
end

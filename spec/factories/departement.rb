# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    name { "Marne" }
    sequence(:code) { |n| (51 + n).to_s }
  end
end

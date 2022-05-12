# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    sequence(:code_insee) { |n| (51_108 + n).to_s }
    departement { "51" }
    phone_number { "01 01 01 01 01" }
  end
end

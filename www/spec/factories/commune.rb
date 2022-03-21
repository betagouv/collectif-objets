# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    code_insee { "51108" }
    departement { "51" }
    phone_number { "01 01 01 01 01" }
  end
end

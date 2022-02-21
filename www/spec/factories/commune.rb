# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    code_insee { "51108" }
    departement { "51" }
    email { "mairie@chalons.org" }
    phone_number { "01 01 01 01 01" }
    population { 44_426 }
  end
end

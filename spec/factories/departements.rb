# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    nom { "Marne" }
    dans_nom { "dans la #{nom}" }
    sequence(:code) { |n| Departement::CODES[n % Departement::CODES.size] }
    region { Departement::REGIONS.find { |_name, codes| code.in?(codes) }&.first }
  end
end

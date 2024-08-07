# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    nom { "Marne" }
    dans_nom { "dans la Marne" }
    sequence(:code) { |n| Departement::CODES[n % Departement::CODES.length] }
    region { Departement::REGIONS.find { |_name, codes| codes.include? code }&.first }
  end
end

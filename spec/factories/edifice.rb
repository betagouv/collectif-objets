# frozen_string_literal: true

FactoryBot.define do
  factory :edifice do
    sequence(:merimee_REF) { |n| "PA#{n + 51_001_252}" }
    nom { "église saint jean" }
    merimee_PRODUCTEUR { "Monuments Historiques" }
    code_insee { "51002" }
    slug { |n| "eglise-saint-jean-#{n}" }
  end
end

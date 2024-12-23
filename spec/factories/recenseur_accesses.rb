# frozen_string_literal: true

FactoryBot.define do
  factory :recenseur_access do
    recenseur
    commune
  end
end

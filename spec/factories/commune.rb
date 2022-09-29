# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    sequence(:code_insee) { |n| (51_108 + n).to_s }
    # status { "inactive" }
    association :departement
    phone_number { "01 01 01 01 01" }

    factory :commune_with_user do
      users { [association(:user)] }
    end
  end
end

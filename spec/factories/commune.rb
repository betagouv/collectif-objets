# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    sequence(:code_insee) { |n| (n + 51_108).to_s }
    # status { "inactive" }
    association :departement
    phone_number { "01 01 01 01 01" }
    inbound_email_token { "12345678901234567890" }

    factory :commune_with_user do
      users { [association(:user)] }
    end
  end
end

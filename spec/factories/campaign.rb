# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    status { "ongoing" }
    association :departement
    sequence(:date_lancement) do |offset|
      initial_date = Date.new(2030, 1, 7) # monday
      w, d = offset.divmod(5) # offset until fridays only
      initial_date + w.weeks + d.days
    end
    date_relance1 { date_lancement + 2.weeks }
    date_relance2 { date_relance1 + 2.weeks }
    date_relance3 { date_relance2 + 2.weeks }
    date_fin { date_relance3 + 2.weeks }
    sender_name { "Jeanine Sloop" }
    nom_drac { "Grand Est" }
    signature do
      "Jeanne Dupont\n\nConservatrice en charge des monuments historiques\n" \
        "DRAC Rhône-Alpes, Châlons-sur-Saone, 10 rue de la république"
    end
  end
end

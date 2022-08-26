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
    date_rappel1 { date_lancement + 2.weeks }
    date_rappel2 { date_rappel1 + 2.weeks }
    date_rappel3 { date_rappel2 + 2.weeks }
    date_fin { date_rappel3 + 2.weeks }
    sender_name { "Jeanine Sloop" }
    nom_drac { "Grand Est" }
    signature do
      "Jeanne Dupont\n\nConservatrice en charge des monuments historiques\n" \
        "DRAC Rhône-Alpes, Châlons-sur-Saone, 10 rue de la république"
    end
  end
end

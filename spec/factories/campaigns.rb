# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    status { :ongoing }
    departement_code { "51" }
    departement do
      region = Departement::REGIONS.find { |_name, codes| departement_code.in?(codes) }&.first
      association :departement, code: departement_code, region:
    end
    sequence(:date_lancement) do |offset|
      initial_date = Date.new(2030, 1, 7) # Monday
      w, d = offset.divmod(5) # offset until Friday only
      initial_date + w.weeks + d.days
    end
    date_relance1 { date_lancement + 2.weeks }
    date_relance2 { date_relance1 + 2.weeks }
    date_relance3 { date_relance2 + 2.weeks }
    date_fin { date_relance3 + 2.weeks }
    sender_name { "Jeanine Sloop" }
    nom_drac { departement.region }
    signature do
      "Jeanne Dupont\n\nConservatrice en charge des monuments historiques\n" \
        "DRAC #{nom_drac}, Châlons-sur-Saone, 10 rue de la république"
    end

    trait :draft do
      status { :draft }
    end

    trait :planned do
      status { :planned }
    end

    trait :ongoing do
      status { :ongoing }
    end

    trait :finished do
      status { :finished }
    end

    trait :with_communes do
      communes do
        [association(:commune), association(:commune_en_cours_de_recensement), association(:commune_a_examiner),
         association(:commune_en_cours_dexamen), association(:commune_examinée)]
      end
    end

    factory :campaign_planned, traits: [:planned]
    factory :campaign_planned_with_communes, traits: [:planned, :with_communes]
  end
end

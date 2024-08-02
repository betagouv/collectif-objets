# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    nom { "Châlons-en-Champagne" }
    sequence(:code_insee) { |n| (n + 51_108).to_s }
    # status { "inactive" }
    association :departement
    phone_number { "01 01 01 01 01" }
    inbound_email_token { "12345678901234567890" }

    trait :with_user do
      users { [association(:user, commune: instance)] }
    end

    trait :with_objets do
      objets { [association(:objet, commune: instance), association(:objet, commune: instance)] }
    end

    trait :recensable do
      with_user
      with_objets
    end

    trait :en_cours_de_recensement do
      status { "started" }
      dossier { association(:dossier, commune: instance) }
    end

    trait :completed do
      with_user
      status { "completed" }
      dossier { association(:dossier, :submitted, commune: instance) }
    end

    trait :en_cours_d_examen do
      status { "completed" }
      dossier { association(:dossier_en_cours_dexamen, commune: instance) }
    end

    trait :examinée do
      status { "completed" }
      dossier { association(:dossier_examiné, commune: instance) }
    end

    factory :commune_with_user, traits: [:with_user]
    factory :commune_recensable, traits: [:recensable], aliases: [:commune_non_recensée]
    factory :commune_completed, traits: %i[recensable completed], aliases: [:commune_a_examiner]
    factory :commune_en_cours_de_recensement, traits: [:recensable, :en_cours_de_recensement]
    factory :commune_en_cours_dexamen, traits: [:recensable, :en_cours_d_examen]
    factory :commune_examinée, traits: [:recensable, :examinée]
  end
end

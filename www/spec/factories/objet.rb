# frozen_string_literal: true

FactoryBot.define do
  factory :objet do
    sequence(:ref_pop) { |n| "PM#{51_001_252 + n}" }
    ref_memoire { "AP80L043503" }
    nom { "Sainte-Famille (La)" }
    categorie { "Peinture" }
    # commune_code_insee { "" }
    # commune_nom { "" }
    # departement { "" }
    crafted_at { "16e siècle" }
    # last_recolement_at { "" }
    nom_dossier { "Dossier individuel" }
    edifice_nom { "Eglise Notre-Dame-en-Vaux" }
    emplacement { "dans la nef droite" }
    recolement_status { "" }

    association :commune

    trait :without_image do
      # do nothing
    end

    trait :with_image do
      image_urls { ["https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L043503/sap04_80l043503_p.jpg"] }
    end
  end
end

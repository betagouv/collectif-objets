# frozen_string_literal: true

FactoryBot.define do
  factory :objet do
    sequence(:palissy_REF) { |n| "PM#{51_001_252 + n}" }
    memoire_REF { "AP80L043503" }
    palissy_TICO { "Sainte-Famille (La)" }
    palissy_CATE { "Peinture" }
    # palissy_INSEE { "" }
    # palissy_COM { "" }
    # palissy_DPT { "" }
    palissy_SCLE { "16e siècle" }
    # palissy_DENQ { "" }
    palissy_DOSS { "Dossier individuel" }
    palissy_EDIF { "Eglise Notre-Dame-en-Vaux" }
    palissy_EMPL { "dans la nef droite" }

    association :commune
    association :edifice

    trait :without_image do
      # do nothing
    end

    trait :with_recensement do
      recensements { [association(:recensement)] }
    end

    trait :with_image do
      palissy_photos do
        [
          {
            "url" => "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L043503/sap04_80l043503_p.jpg",
            "credit" => "© Médiathèque Paris"
          }
        ]
      end
    end
  end
end

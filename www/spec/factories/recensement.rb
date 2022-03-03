# frozen_string_literal: true

FactoryBot.define do
  factory :recensement do
    association :objet
    localisation { Recensement::LOCALISATION_EDIFICE_INITIAL }
    recensable { true }
    edifice_nom { nil }
    etat_sanitaire { Recensement::ETAT_BON }
    etat_sanitaire_edifice { Recensement::ETAT_CORRECT }
    securisation { Recensement::SECURISATION_CORRECTE }
    notes { "objet très doux" }
    skip_photos { true }

    trait :without_image do
      # do nothing
    end

    trait :with_image do
      # image_urls { ["https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L043503/sap04_80l043503_p.jpg"] }
    end
  end
end

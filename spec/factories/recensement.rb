# frozen_string_literal: true

FactoryBot.define do
  factory :recensement do
    association :objet
    association :user
    association :dossier
    confirmation_sur_place { true }
    localisation { Recensement::LOCALISATION_EDIFICE_INITIAL }
    recensable { true }
    edifice_nom { nil }
    etat_sanitaire { Recensement::ETAT_BON }
    etat_sanitaire_edifice { Recensement::ETAT_MOYEN }
    securisation { Recensement::SECURISATION_CORRECTE }
    notes { "objet très doux" }
    confirmation_pas_de_photos { true }

    trait :empty do
      confirmation_sur_place { nil }
      localisation { nil }
      recensable { nil }
      edifice_nom { nil }
      etat_sanitaire { nil }
      etat_sanitaire_edifice { nil }
      securisation { nil }
      notes { nil }
      confirmation_pas_de_photos { nil }
    end

    trait :with_photo do
      confirmation_pas_de_photos { false }

      after(:build) do |recensement|
        recensement.photos.attach(
          io: Rails.root.join("spec/fixture_files/tableau1.jpg").open,
          filename: "tableau1.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end

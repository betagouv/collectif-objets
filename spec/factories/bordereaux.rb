# frozen_string_literal: true

FactoryBot.define do
  factory :bordereau do
    dossier { association(:dossier, :examiné, :with_conservateur) }
    edifice { association(:edifice, commune: dossier.commune, objets_count: 2) }

    trait(:with_recensements) do
      after(:build) do |bordereau|
        dossier = bordereau.dossier
        dossier.save
        bordereau.edifice.objets.each do |objet|
          create(:recensement, :examiné, objet:, dossier:)
        end
      end
    end
  end
end

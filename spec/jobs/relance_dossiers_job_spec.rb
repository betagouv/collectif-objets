# frozen_string_literal: true

require "rails_helper"

RSpec.describe RelanceDossiersJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let(:departement) { create(:departement) } # Reuse departement to avoid extra CREATE queries
    it "relance les dossiers" do
      dossiers = {}
      { a_relancer: RelanceDossiersJob::MOIS_RELANCE,
        derniere_relance: RelanceDossiersJob::MOIS_DERNIERE_RELANCE }.each do |kind, i|
        dossiers[kind] ||= []
        [:beginning_of_month, :end_of_month].each do |time_of_month|
          commune = create(:commune, :with_user, departement:)
          created_at = i.months.ago.send(time_of_month)
          dossiers[kind] << create(:dossier, commune:, created_at:, status: :construction).id
        end
      end

      # Vérifie que les dossiers des mois concernés sont sélectionnés
      expect(RelanceDossiersJob.dossiers_a_relancer).to eq dossiers[:a_relancer]
      expect(RelanceDossiersJob.dossiers_pour_derniere_relance).to eq dossiers[:derniere_relance]

      # Vérifie que les dossiers sont envoyés aux bons mailers
      dossiers[:a_relancer].each do |dossier_id|
        expect(RelanceDossierIncompletJob).to receive(:perform_later).with(dossier_id)
      end
      dossiers[:derniere_relance].each do |dossier_id|
        expect(DerniereRelanceDossierIncompletJob).to receive(:perform_later).with(dossier_id)
      end

      RelanceDossiersJob.new.perform
    end
  end
end

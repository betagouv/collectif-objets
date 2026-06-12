# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaigns::CronJob, type: :job do
  include ActiveJob::TestHelper

  describe "for planned campaigns" do
    let(:base_date) { 1.year.from_now.at_beginning_of_week }
    let!(:campaign1) { create(:campaign, :planned, date_lancement: base_date + 1.week, departement_code: "01") }
    let!(:campaign2) { create(:campaign, :planned, date_lancement: base_date - 1.week, departement_code: "02") }
    let!(:campaign3) { create(:campaign, :planned, date_lancement: base_date - 1.week, departement_code: "03") }
    let!(:campaign4) { create(:campaign, :planned, date_lancement: base_date + 2.weeks, departement_code: "04") }

    it "should start only planned campaign with lancement date in the past" do
      expect(Campaigns::RunCampaignJob).not_to receive(:perform_now).with(campaign1.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign2.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign3.id)
      expect(Campaigns::RunCampaignJob).not_to receive(:perform_now).with(campaign4.id)

      Campaigns::CronJob.new.perform(base_date)

      expect(campaign1.reload.status).to eq("planned")
      expect(campaign2.reload.status).to eq("ongoing")
      expect(campaign3.reload.status).to eq("ongoing")
      expect(campaign4.reload.status).to eq("planned")
    end
  end

  describe "for ongoing campaigns" do
    let(:departement) { create(:departement, code: "51") }
    let(:base_date) { 1.year.from_now.at_beginning_of_week }
    let!(:campaign1) do
      create(:campaign, :draft, departement:, date_lancement: base_date, date_fin: base_date + 8.weeks)
    end
    let!(:campaign2) do
      create(:campaign, :ongoing, departement:, date_lancement: base_date, date_fin: base_date + 10.weeks)
    end
    let!(:campaign3) do
      create(:campaign, :ongoing, departement:, date_lancement: base_date, date_fin: base_date + 9.weeks)
    end
    let!(:campaign4) do
      create(:campaign, :ongoing, departement:, date_lancement: base_date, date_fin: base_date + 12.weeks)
    end
    let!(:campaign5) do
      create(:campaign, :ongoing, departement:, date_lancement: base_date, date_fin: base_date + 7.weeks)
    end

    it "should enqueue ongoing campaigns only" do
      expect(Campaigns::RunCampaignJob).not_to receive(:perform_now).with(campaign1.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign2.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign3.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign4.id)
      expect(Campaigns::RunCampaignJob).to receive(:perform_now).with(campaign5.id)

      Campaigns::CronJob.new.perform(base_date + 9.weeks)

      expect(campaign1.reload.status).to eq("draft") # in draft state
      expect(campaign2.reload.status).to eq("ongoing")
      expect(campaign3.reload.status).to eq("ongoing") # still ongoing because date_fin = today
      expect(campaign4.reload.status).to eq("ongoing")
      expect(campaign5.reload.status).to eq("finished") # finished because date_fin < today
    end
  end

  describe "pour les campagnes ayant atteint la date de fin" do
    let(:departement) { create(:departement, code: "51") }
    let!(:commune_sans_objets_prioritaires) { create(:commune_completed) }
    let!(:commune_avec_objets_prioritaires) { create(:commune_completed) }
    let!(:recensement_en_peril) { create(:recensement, :en_peril, dossier: commune_avec_objets_prioritaires.dossier) }
    let!(:commune_en_cours_dexamen) { create(:commune_completed) }
    let!(:recensement_examiné) { create(:recensement, :examiné, dossier: commune_en_cours_dexamen.dossier) }
    let!(:campagne_en_cours_apres_date_fin) do
      create(:campaign, status: "ongoing", date_lancement: Date.new(2023, 10, 10), date_fin: Date.new(2023, 11, 10),
                        departement:)
    end
    let!(:campagne_non_concernee) do
      create(:campaign, status: :finished, date_lancement: Date.new(2023, 9, 1), departement:)
    end
    let!(:commune_sans_objets_prioritaires2) { create(:commune_completed) }

    before do
      campagne_en_cours_apres_date_fin.communes = [commune_sans_objets_prioritaires, commune_avec_objets_prioritaires,
                                                   commune_en_cours_dexamen]
      campagne_non_concernee.communes << commune_sans_objets_prioritaires2
    end

    it "envoie un email aux communes avec uniquement des objets verts \
        ayant fini leur recensement il y a plus d'un jour et ayant démarré après le 05/10/2023" do
      commune_sans_objets_prioritaires.dossier.update(submitted_at: Date.new(2023, 11, 14))
      commune_sans_objets_prioritaires2.dossier.update(submitted_at: Date.new(2023, 9, 15))

      Campaigns::CronJob.new.perform(Date.new(2023, 11, 16))
      perform_enqueued_jobs

      expect(ActionMailer::Base.deliveries.count).to eq(1)
      expect(commune_sans_objets_prioritaires.dossier.reload.replied_automatically_at).not_to be_nil
    end
  end
end

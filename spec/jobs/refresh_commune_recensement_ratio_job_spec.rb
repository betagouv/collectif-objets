# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefreshCommuneRecensementRatioJob, type: :job do
  describe "#perform" do
    let!(:commune) { create(:commune) }

    subject do
      RefreshCommuneRecensementRatioJob.perform_now(commune.id)
      commune.reload.recensement_ratio
    end

    context "single commune without objets" do
      it { should be_nil }
    end

    context "single commune with objets" do
      let!(:commune) { create(:commune_en_cours_de_recensement) }
      let!(:objet1) { create(:objet, commune:) }
      let!(:objet2) { create(:objet, commune:) }

      context "with no recensement" do
        it { should eq 0 }
      end

      context "with half recensements", skip: true do
        let!(:recensement1) { create(:recensement, objet: objet1, dossier: commune.dossier) }
        it { should eq 50 }
      end

      context "with all recensements", skip: true do
        let!(:recensement1) { create(:recensement, objet: objet1, dossier: commune.dossier) }
        let!(:recensement2) { create(:recensement, objet: objet2, dossier: commune.dossier) }
        it { should eq 100 }
      end
    end
  end
end

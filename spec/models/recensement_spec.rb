# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recensement, type: :model do
  describe "validations" do
    subject { recensement.valid? }

    context "basic recensement from factory" do
      let(:recensement) { build(:recensement) }
      it { should eq true }
    end

    context "recensement without etat_sanitaire" do
      let(:recensement) { build(:recensement, etat_sanitaire: nil) }
      it { should eq false }
    end

    context "recensement autre edifice with edifice_nom" do
      let(:recensement) do
        build(:recensement, localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: "blah")
      end
      it { should eq true }
    end

    context "recensement autre edifice without edifice_nom" do
      let(:recensement) { build(:recensement, localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: nil) }
      it { should eq false }
    end

    context "recensement introuvable" do
      let(:attributes) do
        { localisation: Recensement::LOCALISATION_ABSENT, recensable: false, etat_sanitaire: nil, securisation: nil }
      end

      context "other fields empty" do
        let(:recensement) { build(:recensement, attributes) }
        it do
          expect(recensement.valid?).to eq true
        end
      end

      context "recensable true" do
        let(:recensement) { build(:recensement, attributes.merge(recensable: true)) }
        it { should eq false }
      end

      context "etat_sanitaire filled" do
        let(:recensement) { build(:recensement, attributes.merge(etat_sanitaire: Recensement::ETAT_BON)) }
        it { should eq false }
      end

      context "with existing photo" do
        let(:recensement) { build(:recensement, :with_photo, attributes) }
        it { should eq false }
      end

      context "trouvable with existing photo, updating to introuvable without removing photos" do
        let!(:recensement) { create(:recensement, :with_photo) }
        before { recensement.assign_attributes(attributes) }
        it { should eq false }
      end

      context "with existing photo, updating to remove it" do
        let!(:recensement) { create(:recensement, :with_photo) }
        before { recensement.assign_attributes(attributes.merge(photos: [])) }
        it { should eq true }
      end
    end

    context "recensement non recensable" do
      let(:attributes) { { recensable: false, etat_sanitaire: nil, securisation: nil } }

      context "other fields empty" do
        let(:recensement) { build(:recensement, attributes) }
        it { should eq true }
      end

      context "autre edifice with edifice_nom set" do
        let(:recensement) do
          build(:recensement,
                attributes.merge(localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: "autre eglise"))
        end
        it { should eq true }
      end

      context "autre edifice with edifice_nom not set" do
        let(:recensement) do
          build(:recensement,
                attributes.merge(localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: nil))
        end
        it { should eq false }
      end

      context "etat_sanitaire filled" do
        let(:recensement) { build(:recensement, attributes.merge(etat_sanitaire: Recensement::ETAT_BON)) }
        it { should eq false }
      end

      context "with existing photo" do
        let(:recensement) { build(:recensement, :with_photo, attributes) }
        it { should eq false }
      end

      context "recensable with existing photo, updating to non recensable without removing photos" do
        let!(:recensement) { create(:recensement, :with_photo) }
        before { recensement.assign_attributes(attributes) }
        it { should eq false }
      end

      context "with existing photo, updating to remove it" do
        let!(:recensement) { create(:recensement, :with_photo) }
        before { recensement.assign_attributes(attributes.merge(photos: [])) }
        it { should eq true }
      end
    end

    context "another recensement already exists for same objet" do
      let!(:objet) { create(:objet) }
      let!(:existing_recensement) { create(:recensement, objet:) }
      let(:recensement) { build(:recensement, objet:) }
      it { should eq false }
    end
  end

  describe "prevent analyse override equal to original" do
    let!(:recensement) do
      build(:recensement, etat_sanitaire:, analyse_etat_sanitaire:)
    end

    subject do
      recensement.update!(analyse_etat_sanitaire: new_analyse_etat_sanitaire)
      recensement.reload.analyse_etat_sanitaire
    end

    context "trying to set initial override value" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { nil }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      it { should eq Recensement::ETAT_MAUVAIS }
    end

    context "trying to set initial override value to same as original" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { nil }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_BON }
      it { should eq nil }
    end

    context "trying to change override value" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { Recensement::ETAT_MOYEN }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      it { should eq Recensement::ETAT_MAUVAIS }
    end

    context "trying to change override value to same as original" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_BON }
      it { should eq nil }
    end
  end

  describe "#complete" do
    subject { recensement.complete }

    context "success for first recensement" do
      let!(:commune) { create(:commune, status: "inactive") }
      let!(:objet) { create(:objet, commune:) }
      let!(:user) { create(:user, commune:) }

      let(:recensement) do
        Recensement.new(
          objet:,
          user:,
          confirmation_sur_place: true,
          localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
          recensable: true,
          edifice_nom: nil,
          etat_sanitaire: Recensement::ETAT_BON,
          securisation: Recensement::SECURISATION_CORRECTE,
          notes: "objet très doux"
        )
      end

      before do
        expect(commune).to receive(:start!).and_return(true)
        expect(SendMattermostNotificationJob).to receive(:perform_async)
      end

      it "should work" do
        res = subject
        expect(res).to be true
        expect(recensement.persisted?).to be true
      end
    end

    context "success for successive recensement" do
      let!(:commune) { create(:commune, status: "started") }
      let!(:dossier) { create(:dossier, commune:, status: "construction") }
      before { commune.update!(dossier:) }
      let!(:objet) { create(:objet, commune:) }
      let!(:user) { create(:user, commune:) }

      let(:recensement) do
        Recensement.new(
          objet:,
          user:,
          confirmation_sur_place: true,
          localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
          recensable: true,
          edifice_nom: nil,
          etat_sanitaire: Recensement::ETAT_BON,
          securisation: Recensement::SECURISATION_CORRECTE,
          notes: "objet très doux"
        )
      end

      before do
        expect(commune).not_to receive(:start!)
        expect(SendMattermostNotificationJob).to receive(:perform_async)
      end

      it "should work" do
        res = subject
        expect(res).to be true
        expect(recensement.persisted?).to be true
        expect(recensement.dossier).to eq dossier
      end
    end

    context "failure - wrong params" do
      let!(:commune) { create(:commune, status: "inactive") }
      let!(:objet) { create(:objet, commune:) }
      let!(:user) { create(:user, commune:) }

      let(:recensement) do
        Recensement.new(
          objet:,
          user:,
          localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
          recensable: true,
          edifice_nom: nil,
          # etat_sanitaire: Recensement::ETAT_BON,
          securisation: Recensement::SECURISATION_CORRECTE,
          notes: "objet très doux"
        )
      end

      before do
        expect(commune).not_to receive(:start!)
        expect(SendMattermostNotificationJob).not_to receive(:perform_async)
      end

      it "should work" do
        res = subject
        expect(res).to be false
        expect(recensement.persisted?).to be false
        expect(recensement.errors.count).to be > 1
      end
    end
  end
end

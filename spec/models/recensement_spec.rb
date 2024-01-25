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

  describe "#complete!" do
    subject(:do_complete!) { recensement.complete! }

    describe "#complete! pour une commune inactive" do
      let!(:commune) { create(:commune, status: "inactive") }
      let!(:objet) { create(:objet, commune:) }
      let(:recensement) { create(:recensement, objet:, status: "draft", dossier: nil) }
      it "change le statut du recensement et de la commune et créé un dossier" do
        expect(SendMattermostNotificationJob).to \
          receive(:perform_later).with("recensement_created", { "recensement_id" => an_instance_of(Integer) })
        do_complete!
        expect(recensement.reload.status.to_sym).to eq :completed
        expect(recensement.reload.dossier).to be_present
        expect(recensement.reload.dossier.status.to_sym).to eq :construction
        expect(recensement.reload.dossier.commune.status.to_sym).to eq :started
        expect(commune.reload.dossier).to eq recensement.reload.dossier
      end
    end

    describe "#complete! pour une commune started" do
      let!(:commune) { create(:commune, status: "started") }
      let!(:dossier) { create(:dossier, status: "construction", commune:) }
      before { commune.update!(dossier:) }
      let!(:objet) { create(:objet, commune:) }
      let(:recensement) { create(:recensement, objet:, status: "draft", dossier: nil) }
      it "change le statut du recensement et réutilise le dossier existant" do
        expect(SendMattermostNotificationJob).to \
          receive(:perform_later).with("recensement_created", { "recensement_id" => an_instance_of(Integer) })
        initial_dossier_count = Dossier.count
        do_complete!
        expect(recensement.reload.status.to_sym).to eq :completed
        expect(recensement.reload.dossier).to be_present
        expect(recensement.reload.dossier.status.to_sym).to eq :construction
        expect(commune.reload.status.to_sym).to eq :started
        expect(commune.reload.dossier).to eq recensement.reload.dossier
        expect(Dossier.count).to eq initial_dossier_count
      end
    end

    describe "#complete! pour une commune inactive mais une erreur se produit" do
      let!(:commune) { create(:commune, status: "inactive") }
      let!(:objet) { create(:objet, commune:) }
      let(:recensement) { create(:recensement, objet:, status: "draft", dossier: nil) }
      before do
        def recensement.aasm_after_complete
          super
          raise ActiveRecord::RecordInvalid
        end
      end
      it "annule tous les changements" do
        expect(SendMattermostNotificationJob).not_to receive(:perform_later)
        initial_dossier_count = Dossier.count
        expect { do_complete! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(recensement.reload.status.to_sym).to eq :draft
        expect(commune.reload.status.to_sym).to eq :inactive
        expect(commune.reload.dossier).to be_nil
        expect(Dossier.count).to eq initial_dossier_count
      end
    end
  end

  describe ".prioritaires" do
    subject { Recensement.prioritaires.count }

    context "aucun recensement prioritaire" do
      let!(:recensement) { create(:recensement) }
      it { should eq 0 }
    end

    context "avec un recensement en peril" do
      let!(:recensement) { create(:recensement, :en_peril) }
      it { should eq 1 }
    end

    context "avec un recensement disparu" do
      let!(:recensement) { create(:recensement, :disparu) }
      it { should eq 1 }
    end
  end
end

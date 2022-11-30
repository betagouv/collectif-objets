# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetRevision do
  context "nouvel objet simple" do
    let(:commune) { build(:commune, status: :inactive) }
    let(:objet) { build(:objet, commune:, palissy_REF: "PM01000001", palissy_DENO: "tableau") }
    let(:revision) { described_class.new(objet:, commune:) }
    it "should be valid" do
      expect(revision.valid?).to eq(true)
      expect(revision.action).to eq(:create)
      expect(revision.objet.palissy_REF).to eq("PM01000001")
      expect(revision.objet.palissy_DENO).to eq "tableau"
    end
  end

  context "TICO en cours de traitement" do
    let(:commune) { build(:commune, status: :inactive) }
    let(:objet) { build(:objet, commune:, palissy_TICO: "Traitement en cours") }
    let(:revision) { described_class.new(objet:, commune:) }
    it "should be valid" do
      expect(revision.valid?).to eq(false)
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/l'objet est en cours de traitement/)
    end
  end

  context "commune est started" do
    let(:commune) { build(:commune, status: :started) }
    let(:objet) { build(:objet, commune:) }
    let(:revision) { described_class.new(objet:, commune:) }
    it "should not be valid" do
      expect(revision.valid?).to eq false
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/la commune .* est started/)
    end
  end

  context "commune manquante" do
    let(:objet) { build(:objet, commune: nil) }
    it "should raise" do
      expect { described_class.new(objet:).valid? }.to raise_error(StandardError)
    end
  end

  context "update" do
    let!(:commune_before_update) { create(:commune, status: :inactive) }
    let!(:objet) do
      create(
        :objet,
        commune: commune_before_update,
        palissy_DENO: "tableau",
        palissy_CATE: "peinture",
        palissy_COM: "Ambérieu-en-Bugey",
        palissy_INSEE: "01004",
        palissy_DPT: "01",
        palissy_SCLE: nil,
        palissy_DENQ: "2001",
        palissy_DOSS: "dossier individuel",
        palissy_EDIF: "chapelle des Allymes",
        palissy_EMPL: "chapelle située au milieu du cimetière",
        palissy_TICO: "Tableau : Vierge du Rosaire"
      )
    end

    context "no changes" do
      let(:revision) { described_class.new(objet:, commune: commune_before_update, commune_before_update:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :not_changed
      end
    end

    context "some updates" do
      before do
        objet.assign_attributes(
          palissy_DENO: "tableau bleu",
          palissy_SCLE: "1er quart 18e siècle",
          palissy_DOSS: "sous-dossier",
          palissy_TICO: "Tableau super grand",
          palissy_DENQ: nil
        )
      end

      let(:revision) { described_class.new(objet:, commune: commune_before_update, commune_before_update:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
        expect(revision.log_message).to match(/tableau bleu/)
        expect(revision.objet.palissy_SCLE).to eq "1er quart 18e siècle"
      end
    end

    context "commune initiale started & no changes" do
      let(:commune_before_update) { build(:commune, status: :started) }
      let(:revision) { described_class.new(objet:, commune: commune_before_update, commune_before_update:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :not_changed
      end
    end

    context "commune initiale started & some minor changes" do
      let(:commune_before_update) { build(:commune, status: :started) }
      before { objet.assign_attributes(palissy_DENQ: "2021") }
      let(:revision) { described_class.new(objet:, commune: commune_before_update, commune_before_update:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
      end
    end

    context "commune initiale started & some major changes" do
      let(:commune_before_update) { build(:commune, status: :started) }
      before { objet.assign_attributes(palissy_DENO: "tableau bleu") }
      let(:revision) { described_class.new(objet:, commune: commune_before_update, commune_before_update:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.log_message).to match(/tableau bleu/)
      end
    end

    context "changement de commune depuis inactive vers autre inactive avec des changements importants" do
      let(:commune_before_update) { build(:commune, status: :inactive) }
      let(:commune_after_update) { build(:commune, status: :inactive, code_insee: "01203") }
      before do
        objet.assign_attributes(
          palissy_INSEE: "01203",
          palissy_DENO: "tableau bleu"
        )
      end
      let(:revision) { described_class.new(objet:, commune: commune_after_update, commune_before_update:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
      end
    end

    context "changement de commune depuis inactive vers started avec des changements importants" do
      let(:commune_before_update) { build(:commune, status: :inactive) }
      let(:commune_after_update) { build(:commune, status: :started, code_insee: "01203") }
      before do
        objet.assign_attributes(
          palissy_INSEE: "01203",
          palissy_DENO: "tableau bleu"
        )
      end
      let(:revision) { described_class.new(objet:, commune: commune_after_update, commune_before_update:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.log_message).to match(/la commune .* est started/)
      end
    end

    context "changement de commune depuis started vers inactive avec des changements importants" do
      let(:commune_before_update) { build(:commune, status: :started) }
      let(:commune_after_update) { build(:commune, status: :inactive, code_insee: "01203") }
      before do
        objet.assign_attributes(
          palissy_INSEE: "01203",
          palissy_DENO: "tableau bleu"
        )
      end
      let(:revision) { described_class.new(objet:, commune: commune_after_update, commune_before_update:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.log_message).to match(/la commune initiale .* est started/)
      end
    end
  end
end

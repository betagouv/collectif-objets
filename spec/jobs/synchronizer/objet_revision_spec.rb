# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetRevision do
  let(:base_row) do
    {
      "REF" => "PM01000001",
      "DENO" => '["tableau"]',
      "CATE" => '["peinture"]',
      "COM" => "Ambérieu-en-Bugey",
      "INSEE" => "01004",
      "DPT" => "01",
      "SCLE" => '["1er quart 17e siècle"]',
      "DENQ" => '["2001"]',
      "DOSS" => "dossier individuel",
      "EDIF" => "chapelle des Allymes",
      "EMPL" => "chapelle située au milieu du cimetière",
      "TICO" => "Tableau : Vierge du Rosaire"
    }
  end

  context "nouvel objet simple" do
    let!(:commune) { create(:commune, code_insee: "01004", status: :inactive) }
    let(:revision) { described_class.new(base_row) }
    it "should be valid" do
      expect(revision.valid?).to eq(true)
      expect(revision.action).to eq(:create)
      expect(revision.objet.palissy_REF).to eq("PM01000001")
      expect(revision.objet.palissy_DENO).to eq "tableau"
    end
  end

  context "nouvel objet simple avec commune préfetchée passée en param" do
    let(:commune) { build(:commune, code_insee: "01004", status: :inactive) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "should be valid" do
      expect(revision.valid?).to eq(true)
      expect(revision.action).to eq(:create)
      expect(revision.objet.palissy_REF).to eq("PM01000001")
      expect(revision.objet.palissy_DENO).to eq "tableau"
    end
  end

  context "TICO en cours de traitement" do
    let(:commune) { build(:commune, code_insee: "01004", status: :inactive) }
    let(:row) { base_row.merge("TICO" => "Traitement en cours") }
    let(:revision) { described_class.new(row, commune:) }
    it "should be valid" do
      expect(revision.valid?).to eq(false)
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/l'objet est en cours de traitement/)
    end
  end

  context "commune est started" do
    let(:commune) { build(:commune, code_insee: "01004", status: :started) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "should not be valid" do
      expect(revision.valid?).to eq false
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/la commune .* est started/)
    end
  end

  context "commune est completed" do
    let(:commune) { build(:commune, code_insee: "01004", status: :completed) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "should not be valid" do
      expect(revision.valid?).to eq false
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/la commune .* est completed/)
    end
  end

  context "commune est completed + dossier accepted" do
    let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
    let!(:dossier) { create(:dossier, :accepted, commune:, conservateur: create(:conservateur)) }
    before { commune.update!(dossier:) }
    let(:revision) { described_class.new(base_row) }
    it "should be valid" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq(:create)
    end
  end

  context "commune est started + apply_safe_changes" do
    let(:commune) { build(:commune, code_insee: "01004", status: :started) }
    let(:revision) { described_class.new(base_row, commune:, on_sensitive_change: :apply_safe_changes) }
    it "should not be valid" do
      expect(revision.valid?).to eq false
      expect(revision.action).to eq(:create_invalid)
      expect(revision.log_message).to match(/la commune .* est started/)
    end
  end

  context "commune manquante" do
    # la commune n’est pas créée avant
    it "should raise" do
      expect { described_class.new(base_row).valid? }.to raise_error(ArgumentError)
    end
  end

  context "update" do
    let!(:persisted_objet) do
      create(
        :objet,
        commune: commune_before_update,
        palissy_DENO: "tableau",
        palissy_CATE: "peinture",
        palissy_COM: "Ambérieu-en-Bugey",
        palissy_INSEE: "01004",
        palissy_DPT: "01",
        palissy_SCLE: "1er quart 17e siècle",
        palissy_DENQ: "2001",
        palissy_DOSS: "dossier individuel",
        palissy_EDIF: "chapelle des Allymes",
        palissy_EMPL: "chapelle située au milieu du cimetière",
        palissy_TICO: "Tableau : Vierge du Rosaire"
      )
    end

    context "no changes" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let(:revision) { described_class.new(base_row, persisted_objet:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :not_changed
      end
    end

    context "some safe updates" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let(:row) do
        base_row.merge(
          "DENO" => %(["tableau bleu"]),
          "SCLE" => %(["1er quart 18e siècle"]),
          "DOSS" => "sous-dossier",
          "TICO" => "Tableau super grand",
          "DENQ" => nil
        )
      end

      let(:revision) { described_class.new(row, persisted_objet:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
        expect(revision.log_message).to match(/tableau bleu/)
        expect(revision.objet.palissy_DENO).to eq "tableau bleu"
        expect(revision.objet.palissy_SCLE).to eq "1er quart 18e siècle"
        expect(revision.objet.palissy_DOSS).to eq "sous-dossier"
        expect(revision.objet.palissy_TICO).to eq "Tableau super grand"
      end
    end

    context "commune initiale started & no changes" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
      let(:revision) { described_class.new(base_row, persisted_objet:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :not_changed
      end
    end

    context "commune initiale started & some minor changes" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
      let(:row) { base_row.merge("DENQ" => %(["2021"])) }
      let(:revision) { described_class.new(row, persisted_objet:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
      end
    end

    context "changement de commune depuis started" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :inactive) }
      let(:row) { base_row.merge("INSEE" => "01999") }
      let(:revision) { described_class.new(row, persisted_objet:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.log_message).to match(/01999/)
      end
    end

    context "changement de commune depuis inactive vers autre inactive" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :inactive) }
      let(:row) { base_row.merge("INSEE" => "01999") }
      let(:revision) { described_class.new(row, persisted_objet:) }
      it "should be marked for update" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
      end
    end

    context "changement de commune depuis inactive vers started" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
      let(:row) { base_row.merge("INSEE" => "01999") }
      let(:revision) { described_class.new(row, persisted_objet:) }
      it "should not be marked for update" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.log_message).to match(/la commune .* est started/)
      end
    end

    context "changement de commune depuis inactive vers started + option apply_safe_changes + changements safe" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
      let(:row) { base_row.merge("INSEE" => "01999", "DENO" => %(["très grand tableau"])) }
      let(:revision) { described_class.new(row, persisted_objet:, on_sensitive_change: :apply_safe_changes) }
      it "should be marked for update but only for the safe changes" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :update
        expect(revision.objet.commune.code_insee).to eq "01004"
        expect(revision.objet.palissy_DENO).to eq "très grand tableau"
      end
    end

    context "changement de commune depuis inactive vers started + option apply_safe_changes + aucun changements safe" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
      let(:row) { base_row.merge("INSEE" => "01999") }
      let(:revision) { described_class.new(row, persisted_objet:, on_sensitive_change: :apply_safe_changes) }
      it "should be marked for update but only for the safe changes" do
        expect(revision.valid?).to eq true
        expect(revision.action).to eq :not_changed
        expect(revision.objet.commune.code_insee).to eq "01004"
      end
    end

    context "changement de commune depuis inactive vers started + option interactive + changements safe" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
      let(:row) { base_row.merge("INSEE" => "01999", "DENO" => %(["très grand tableau"])) }
      let(:revision) { described_class.new(row, persisted_objet:, on_sensitive_change: :interactive) }
      it "should be marked update_invalid for all changes" do
        expect(revision.valid?).to eq false
        expect(revision.action).to eq :update_invalid
        expect(revision.objet.commune.code_insee).to eq "01999"
        expect(revision.objet.palissy_DENO).to eq "très grand tableau"
      end
    end
  end
end

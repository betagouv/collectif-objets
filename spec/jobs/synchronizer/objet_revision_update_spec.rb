# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetRevisionUpdate do
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
      "TICO" => "Tableau : Vierge du Rosaire",
      "DPRO" => "2007/01/29 : classé au titre objet",
      "PROT" => "classé au titre objet"
    }
  end

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
      palissy_TICO: "Tableau : Vierge du Rosaire",
      palissy_DPRO: "2007/01/29 : classé au titre objet",
      palissy_PROT: "classé au titre objet"
    )
  end

  context "no changes" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
    let(:revision) { described_class.new(base_row, commune: commune_before_update, persisted_objet:) }
    it "should not update" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :not_changed
      expect(revision.synchronize).to eq false
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
    let(:revision) { described_class.new(row, commune: commune_before_update, persisted_objet:) }
    it "should update objet" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :update
      expect(revision.log_message).to match(/tableau bleu/)
      expect(revision.synchronize).to eq true
      expect(revision.objet.palissy_DENO).to eq "tableau bleu"
      expect(revision.objet.palissy_SCLE).to eq "1er quart 18e siècle"
      expect(revision.objet.palissy_DOSS).to eq "sous-dossier"
      expect(revision.objet.palissy_TICO).to eq "Tableau super grand"
    end
  end

  context "commune started & no changes" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
    let(:revision) { described_class.new(base_row, commune: commune_before_update, persisted_objet:) }
    it "should not update" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :not_changed
      expect(revision.synchronize).to eq false
    end
  end

  context "commune started & some minor changes" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
    let(:row) { base_row.merge("DENQ" => %(["2021"])) }
    let(:revision) { described_class.new(row, commune: commune_before_update, persisted_objet:) }
    it "should update" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :update
      expect(revision.synchronize).to eq true
      expect(revision.objet.palissy_DENQ).to eq "2021"
    end
  end

  context "changement de commune depuis started vers inactive" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
    let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :inactive) }
    let(:row) do
      base_row.merge(
        "INSEE" => "01999",
        "COM" => "Nogent",
        "EDIF" => "Église st-Jean",
        "EMPL" => "au fond à gauche",
        "TICO" => "Rosarium"
      )
    end
    let(:revision) { described_class.new(row, commune: commune_after_update, persisted_objet:) }
    it "sauvegarde uniquement les changements sûrs" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :update_safe
      expect(revision.synchronize).to eq true
      expect(revision.objet.reload.palissy_INSEE).to eq("01004")
      expect(revision.objet.reload.palissy_COM).to eq("Ambérieu-en-Bugey")
      expect(revision.objet.reload.palissy_EDIF).to eq("chapelle des Allymes")
      expect(revision.objet.reload.palissy_EMPL).to eq("chapelle située au milieu du cimetière")
      expect(revision.objet.reload.palissy_TICO).to eq("Rosarium")
    end
  end

  context "changement de commune depuis inactive vers autre inactive" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
    let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :inactive) }
    let(:row) do
      base_row.merge(
        "INSEE" => "01999",
        "COM" => "Nogent",
        "EDIF" => "Église st-Jean",
        "EMPL" => "au fond à gauche",
        "TICO" => "Rosarium"
      )
    end
    let(:revision) { described_class.new(row, commune: commune_after_update, persisted_objet:) }
    it "should save all updates" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :update
      expect(revision.synchronize).to eq true
      expect(revision.objet.reload.palissy_INSEE).to eq("01999")
      expect(revision.objet.reload.palissy_COM).to eq("Nogent")
      expect(revision.objet.reload.palissy_EDIF).to eq("Église st-Jean")
      expect(revision.objet.reload.palissy_EMPL).to eq("au fond à gauche")
      expect(revision.objet.reload.palissy_TICO).to eq("Rosarium")
    end
  end

  context "changement de commune depuis inactive vers started" do
    let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
    let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
    let(:row) do
      base_row.merge(
        "INSEE" => "01999",
        "COM" => "Nogent",
        "EDIF" => "Église st-Jean",
        "EMPL" => "au fond à gauche",
        "TICO" => "Rosarium"
      )
    end
    let(:revision) { described_class.new(row, commune: commune_after_update, persisted_objet:) }
    it "should update safe fields only" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq :update_safe
      expect(revision.synchronize).to eq true
      expect(revision.objet.reload.palissy_INSEE).to eq("01004")
      expect(revision.objet.reload.palissy_COM).to eq("Ambérieu-en-Bugey")
      expect(revision.objet.reload.palissy_EDIF).to eq("chapelle des Allymes")
      expect(revision.objet.reload.palissy_EMPL).to eq("chapelle située au milieu du cimetière")
      expect(revision.objet.reload.palissy_TICO).to eq("Rosarium")
    end
  end
end

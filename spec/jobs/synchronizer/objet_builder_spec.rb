# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetBuilder do
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
      "REFS_MERIMEE" => "PA021384"
    }
  end

  context "all fields are present" do
    let(:objet) { described_class.new(base_row).objet }
    it "parses correctly" do
      expect(objet.palissy_REF).to eq("PM01000001")
      expect(objet.palissy_DENO).to eq "tableau"
      expect(objet.palissy_CATE).to eq "peinture"
      expect(objet.palissy_COM).to eq "Ambérieu-en-Bugey"
      expect(objet.palissy_INSEE).to eq "01004"
      expect(objet.palissy_DPT).to eq "01"
      expect(objet.palissy_SCLE).to eq "1er quart 17e siècle"
      expect(objet.palissy_DENQ).to eq "2001"
      expect(objet.palissy_DOSS).to eq "dossier individuel"
      expect(objet.palissy_EDIF).to eq "chapelle des Allymes"
      expect(objet.palissy_EMPL).to eq "chapelle située au milieu du cimetière"
      expect(objet.palissy_TICO).to eq "Tableau : Vierge du Rosaire"
      expect(objet.palissy_REFA).to eq "PA021384"
      expect(objet.new_record?).to eq true
      expect(objet.persisted?).to eq false
    end
  end

  context "REFA double, un seul en PA" do
    let(:row) do
      base_row.merge("REFS_MERIMEE" => "PI0389756,PA012893")
    end
    let(:objet) { described_class.new(row).objet }
    it "should get the PA as REFA" do
      expect(objet.palissy_REFA).to eq "PA012893"
    end
  end

  context "REFA double, deux en PA" do
    let(:row) do
      base_row.merge("REFS_MERIMEE" => "PA0389756,PA012893")
    end
    let(:objet) { described_class.new(row).objet }
    it "should not get any REFA" do
      expect(objet.palissy_REFA).to eq nil
    end
  end

  context "with existing persisted objet" do
    let!(:persisted_objet) do
      create(
        :objet,
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
        palissy_REFA: "PA021384"
      )
    end

    context "no changes" do
      let(:objet) { described_class.new(base_row, persisted_objet:).objet }
      it "should have no changes" do
        expect(objet.palissy_EMPL).to eq "chapelle située au milieu du cimetière"
        expect(objet.new_record?).to eq false
        expect(objet.persisted?).to eq true
        expect(objet.changed?).to eq false
        expect(objet.changes).to be_empty
      end
    end

    context "some changes" do
      let(:row) { base_row.merge("DENO" => '["tableau bleu et jaune"]', "EDIF" => "mairie") }
      let(:objet) { described_class.new(row, persisted_objet:).objet }
      it "should have applied changes" do
        expect(objet.palissy_DENO).to eq "tableau bleu et jaune"
        expect(objet.palissy_EDIF).to eq "mairie"
        expect(objet.new_record?).to eq false
        expect(objet.persisted?).to eq true
        expect(objet.changed?).to eq true
        expect(objet.changes).not_to be_empty
      end
    end
  end
end

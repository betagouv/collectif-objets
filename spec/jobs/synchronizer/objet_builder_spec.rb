# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetBuilder do
  before { allow(Synchronizer::SynchronizeEdificeJob).to receive(:perform_inline) }

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

  context "merimee edifice is created on the fly, code insee matches" do
    let(:row) { base_row.merge("INSEE" => "01004", "REFS_MERIMEE" => "PA021384") }
    before do
      allow(Synchronizer::SynchronizeEdificeJob).to receive(:perform_inline) do
        Edifice.where(merimee_REF: "PA021384").update!(code_insee: "01004")
      end
    end
    it "should create the edifice and set the objet.edifice_id" do
      expect(Edifice.count).to eq 0
      objet = described_class.new(base_row).objet
      edifice = Edifice.find_by(merimee_REF: "PA021384")
      expect(edifice.merimee_REF).to eq "PA021384"
      expect(edifice.code_insee).to eq "01004"
      expect(objet.edifice).to eq edifice
    end
  end

  context "merimee edifice is created on the fly, but code insees mismatch" do
    let(:row) { base_row.merge("INSEE" => "01004", "REFS_MERIMEE" => "PA021384") }
    before do
      allow(Synchronizer::SynchronizeEdificeJob).to receive(:perform_inline) do
        Edifice.where(merimee_REF: "PA021384").update!(code_insee: "01005")
      end
    end
    it "should create both edifice and set the objet.edifice_id" do
      expect(Edifice.count).to eq 0
      objet = described_class.new(row).objet
      edifice_merimee = Edifice.find_by(merimee_REF: "PA021384")
      expect(edifice_merimee.code_insee).to eq "01005"
      edifice_custom = Edifice.find_by(code_insee: "01004")
      expect(edifice_custom).not_to eq edifice_merimee
      expect(edifice_custom.merimee_REF).to eq nil
      expect(objet.edifice).to eq edifice_custom
    end
  end

  context "merimee edifice already exists" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => "PA021384") }
    let!(:edifice) { create(:edifice, merimee_REF: "PA021384", code_insee: "01004", nom: "Montmir") }
    it "should re-use the existing edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 1
      objet = described_class.new(row).objet
      expect(Edifice.count).to eq 1
      expect(objet.edifice).to eq edifice
      expect(objet.edifice.nom).to eq "Montmir"
    end
  end

  context "merimee edifice already exists but with the wrong code insee" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => "PA021384") }
    let!(:edifice) { create(:edifice, merimee_REF: "PA021384", code_insee: "01005", nom: "Montmir") }
    it "should create a custom edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 1
      objet = described_class.new(row).objet
      expect(Edifice.count).to eq 2
      expect(objet.edifice).not_to eq edifice
      expect(objet.edifice.merimee_REF).to eq nil
      expect(objet.edifice.code_insee).to eq "01004"
      expect(objet.edifice.nom).to eq "eglise de montmirail"
    end
  end

  context "no merimee ref given, custom edifice is created on the fly" do
    let!(:edifice_mismatch1) { create(:edifice, code_insee: "01004", slug: "eglise-jean", nom: "Jean") }
    let!(:edifice_mismatch2) { create(:edifice, code_insee: "01005", slug: "eglise-montmirail", nom: "Montmir") }
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => nil) }
    it "should create both edifice and set the objet.edifice_id" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 2
      objet = described_class.new(row).objet
      expect(Edifice.count).to eq 3
      edifice_custom = objet.edifice
      expect(edifice_custom.nom).to eq "eglise de montmirail"
      expect(edifice_custom.slug).to eq "eglise-montmirail"
      expect(edifice_custom.merimee_REF).to eq nil
    end
  end

  context "no merimee ref given, custom edifice already exists" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => nil) }
    let!(:edifice) { create(:edifice, code_insee: "01004", slug: "eglise-montmirail", nom: "Montmir") }
    let!(:edifice_mismatch) { create(:edifice, code_insee: "01004", slug: "eglise-jean", nom: "Jean") }
    it "should re-use the existing edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 2
      objet = described_class.new(row).objet
      expect(Edifice.count).to eq 2
      expect(objet.edifice).to eq edifice
      expect(objet.edifice.nom).to eq "Montmir"
    end
  end

  context "with existing persisted objet" do
    let!(:edifice) { create(:edifice, merimee_REF: "PA021384") }
    let!(:persisted_objet) do
      create(
        :objet,
        edifice:,
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

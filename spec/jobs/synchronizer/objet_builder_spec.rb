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
      "REFS_MERIMEE" => "PA021384",
      "DPRO" => "2007/01/29 : classé au titre objet",
      "PROT" => "classé au titre objet"
    }
  end

  context "all fields are present" do
    let(:attributes) { described_class.new(base_row).attributes }
    it "parses correctly" do
      expect(attributes["palissy_REF"]).to eq "PM01000001"
      expect(attributes["palissy_DENO"]).to eq "tableau"
      expect(attributes["palissy_CATE"]).to eq "peinture"
      expect(attributes["palissy_COM"]).to eq "Ambérieu-en-Bugey"
      expect(attributes["palissy_INSEE"]).to eq "01004"
      expect(attributes["palissy_DPT"]).to eq "01"
      expect(attributes["palissy_SCLE"]).to eq "1er quart 17e siècle"
      expect(attributes["palissy_DENQ"]).to eq "2001"
      expect(attributes["palissy_DOSS"]).to eq "dossier individuel"
      expect(attributes["palissy_EDIF"]).to eq "chapelle des Allymes"
      expect(attributes["palissy_EMPL"]).to eq "chapelle située au milieu du cimetière"
      expect(attributes["palissy_TICO"]).to eq "Tableau : Vierge du Rosaire"
      expect(attributes["palissy_REFA"]).to eq "PA021384"
      expect(attributes["palissy_DPRO"]).to eq "2007/01/29 : classé au titre objet"
      expect(attributes["palissy_PROT"]).to eq "classé au titre objet"
    end
  end

  context "REFA double, un seul en PA" do
    let(:row) do
      base_row.merge("REFS_MERIMEE" => "PI0389756,PA012893")
    end
    let(:attributes) { described_class.new(row).attributes }
    it "should get the PA as REFA" do
      expect(attributes["palissy_REFA"]).to eq "PA012893"
    end
  end

  context "REFA double, deux en PA" do
    let(:row) do
      base_row.merge("REFS_MERIMEE" => "PA0389756,PA012893")
    end
    let(:attributes) { described_class.new(row).attributes }
    it "should not get any REFA" do
      expect(attributes["palissy_REFA"]).to eq nil
    end
  end

  context "merimee edifice is created on the fly, code insee matches" do
    let(:row) { base_row.merge("INSEE" => "01004", "REFS_MERIMEE" => "PA021384") }
    before do
      allow(Synchronizer::SynchronizeEdificeJob).to receive(:perform_inline) do
        Edifice.where(merimee_REF: "PA021384").update!(code_insee: "01004")
      end
    end
    it "should create the edifice and set the edifice_id" do
      expect(Edifice.count).to eq 0
      attributes = described_class.new(base_row).attributes
      edifice = Edifice.find_by(merimee_REF: "PA021384")
      expect(edifice.merimee_REF).to eq "PA021384"
      expect(edifice.code_insee).to eq "01004"
      expect(attributes["edifice_id"]).to eq edifice.id
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
      attributes = described_class.new(row).attributes
      edifice_merimee = Edifice.find_by(merimee_REF: "PA021384")
      expect(edifice_merimee.code_insee).to eq "01005"
      edifice_custom = Edifice.find_by(code_insee: "01004")
      expect(edifice_custom).not_to eq edifice_merimee
      expect(edifice_custom.merimee_REF).to eq nil
      expect(attributes["edifice_id"]).to eq edifice_custom.id
    end
  end

  context "merimee edifice already exists" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => "PA021384") }
    let!(:edifice) { create(:edifice, merimee_REF: "PA021384", code_insee: "01004", nom: "Montmir") }
    it "should re-use the existing edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 1
      attributes = described_class.new(row).attributes
      expect(Edifice.count).to eq 1
      expect(attributes["edifice_id"]).to eq edifice.id
      expect(Edifice.find(attributes["edifice_id"]).nom).to eq "Montmir"
    end
  end

  context "merimee edifice already exists but with the wrong code insee" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => "PA021384") }
    let!(:edifice) { create(:edifice, merimee_REF: "PA021384", code_insee: "01005", nom: "Montmir") }
    it "should create a custom edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 1
      attributes = described_class.new(row).attributes
      expect(Edifice.count).to eq 2
      expect(attributes["edifice_id"]).not_to eq edifice.id
      edifice2 = Edifice.find(attributes["edifice_id"])
      expect(edifice2.merimee_REF).to eq nil
      expect(edifice2.code_insee).to eq "01004"
      expect(edifice2.nom).to eq "eglise de montmirail"
    end
  end

  context "no merimee ref given, custom edifice is created on the fly" do
    let!(:edifice_mismatch1) { create(:edifice, code_insee: "01004", slug: "eglise-jean", nom: "Jean") }
    let!(:edifice_mismatch2) { create(:edifice, code_insee: "01005", slug: "eglise-montmirail", nom: "Montmir") }
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => nil) }
    it "should create both edifice and set the objet.edifice_id" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 2
      attributes = described_class.new(row).attributes
      expect(Edifice.count).to eq 3
      edifice2 = Edifice.find attributes["edifice_id"]
      expect(edifice2.nom).to eq "eglise de montmirail"
      expect(edifice2.slug).to eq "eglise-montmirail"
      expect(edifice2.merimee_REF).to eq nil
    end
  end

  context "no merimee ref given, custom edifice already exists" do
    let(:row) { base_row.merge("INSEE" => "01004", "EDIF" => "eglise de montmirail", "REFS_MERIMEE" => nil) }
    let!(:edifice) { create(:edifice, code_insee: "01004", slug: "eglise-montmirail", nom: "Montmir") }
    let!(:edifice_mismatch) { create(:edifice, code_insee: "01004", slug: "eglise-jean", nom: "Jean") }
    it "should re-use the existing edifice" do
      expect(Synchronizer::SynchronizeEdificeJob).not_to receive(:perform_inline)
      expect(Edifice.count).to eq 2
      attributes = described_class.new(row).attributes
      expect(Edifice.count).to eq 2
      edifice2 = Edifice.find attributes["edifice_id"]
      expect(edifice2).to eq edifice
      expect(edifice2.nom).to eq "Montmir"
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
        palissy_DPRO: "2007/01/29 : classé au titre objet",
        palissy_REFA: "PA021384",
        palissy_PROT: "classé au titre objet"
      )
    end
    let(:objet_builder) { described_class.new(base_row, persisted_objet:) }
    let(:attributes) { objet_builder.attributes }
    let(:changes) { objet_builder.changes }

    context "no changes" do
      it "should have no changes" do
        expect(attributes["palissy_EMPL"]).to eq "chapelle située au milieu du cimetière"
        expect(changes).to be_empty
      end
    end

    context "some changes" do
      let(:row) { base_row.merge("DENO" => '["tableau bleu et jaune"]', "DENQ" => %(["2021"])) }
      let(:attributes) { described_class.new(row, persisted_objet:).attributes }
      it "should have applied changes" do
        expect(attributes["palissy_DENO"]).to eq "tableau bleu et jaune"
        expect(attributes["palissy_DENQ"]).to eq "2021"
        expect(attributes["changes"]).not_to be_empty
      end
    end

    context "commune change" do
      let(:row) do
        base_row.merge(
          "INSEE" => "01299",
          "COM" => "Nogent",
          "EDIF" => "Église st-Jean",
          "EMPL" => "au fond à gauche",
          "TICO" => "Rosarium"
        )
      end
      let(:attributes) { described_class.new(row, persisted_objet:).attributes }
      it "should have applied changes" do
        expect(attributes["palissy_INSEE"]).to eq "01299"
        expect(attributes["palissy_COM"]).to eq "Nogent"
        expect(attributes["palissy_EDIF"]).to eq "Église st-Jean"
        expect(attributes["palissy_EMPL"]).to eq "au fond à gauche"
        expect(attributes["palissy_TICO"]).to eq "Rosarium"
        expect(attributes["changes"]).not_to be_empty
      end
    end

    context "commune change" do
      let(:row) do
        base_row.merge(
          "INSEE" => "01299",
          "COM" => "Nogent",
          "EDIF" => "Église st-Jean",
          "EMPL" => "au fond à gauche",
          "TICO" => "Rosarium"
        )
      end
      let(:attributes) { described_class.new(row, persisted_objet:, without_commune_change: true).attributes }
      it "should have applied changes" do
        expect(attributes["palissy_INSEE"]).to eq "01004"
        expect(attributes["palissy_COM"]).to eq "Ambérieu-en-Bugey"
        expect(attributes["palissy_EDIF"]).to eq "chapelle des Allymes"
        expect(attributes["palissy_EMPL"]).to eq "chapelle située au milieu du cimetière"
        expect(attributes["palissy_TICO"]).to eq "Rosarium"
        expect(attributes["changes"]).not_to be_empty
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::Objets::RevisionInsert do
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

  context "commune inactive" do
    let!(:commune) { create(:commune, code_insee: "01004", status: :inactive) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "créé l’objet" do
      expect(revision.synchronize).to eq true
      expect(revision.action).to eq :create
      expect(revision.objet.palissy_REF).to eq "PM01000001"
      expect(revision.objet.palissy_DENO).to eq "tableau"
    end
  end

  context "commune en cours de recensement" do
    let(:commune) { build(:commune, code_insee: "01004", status: :started) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "ne créé pas l’objet" do
      expect(revision.synchronize).to eq false
      expect(revision.action).to eq :create_rejected_commune_active
    end
  end

  context "commune a terminé son recensement" do
    let(:commune) { build(:commune, code_insee: "01004", status: :completed) }
    let!(:dossier) { create(:dossier, :submitted, commune:) }
    before { commune.update!(dossier:) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "ne créé pas l’objet" do
      expect(revision.synchronize).to eq false
      expect(revision.action).to eq :create_rejected_commune_active
    end
  end

  context "commune a terminé son recensement mais son dossier a été accepté" do
    let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
    let!(:dossier) { create(:dossier, :accepted, commune:, conservateur: create(:conservateur)) }
    before { commune.update!(dossier:) }
    let(:revision) { described_class.new(base_row, commune:) }
    it "créé l’objet" do
      expect(revision.synchronize).to eq true
      expect(revision.action).to eq :create
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetRevisionInsert do
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
    let(:revision) { described_class.new(base_row, commune:) }
    it "should be valid" do
      expect(revision.valid?).to eq true
      expect(revision.action).to eq(:create)
    end
  end
end

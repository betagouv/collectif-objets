# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetBuilder do
  describe "#attributes" do
    subject { objet_builder.attributes }

    context "full row" do
      let(:row) do
        {
          "REF" => "PM01000001",
          "DENO" => ["tableau"],
          "CATE" => ["peinture"],
          "COM" => "Ambérieu-en-Bugey",
          "INSEE" => "01004",
          "DPT" => "01",
          "SCLE" => ["1er quart 17e siècle"],
          "DENQ" => ["2001"],
          "DOSS" => "dossier individuel",
          "EDIF" => "chapelle des Allymes",
          "EMPL" => "chapelle située au milieu du cimetière",
          "TICO" => "Tableau : Vierge du Rosaire"
        }
      end
      let(:objet_builder) { described_class.new(row) }
      it "should have values parsed" do
        expect(subject["palissy_REF"]).to eq("PM01000001")
        expect(subject["palissy_DENO"]).to eq "tableau"
        expect(subject["palissy_CATE"]).to eq "peinture"
        expect(subject["palissy_COM"]).to eq "Ambérieu-en-Bugey"
        expect(subject["palissy_INSEE"]).to eq "01004"
        expect(subject["palissy_DPT"]).to eq "01"
        expect(subject["palissy_SCLE"]).to eq "1er quart 17e siècle"
        expect(subject["palissy_DENQ"]).to eq "2001"
        expect(subject["palissy_DOSS"]).to eq "dossier individuel"
        expect(subject["palissy_EDIF"]).to eq "chapelle des Allymes"
        expect(subject["palissy_EMPL"]).to eq "chapelle située au milieu du cimetière"
        expect(subject["palissy_TICO"]).to eq "Tableau : Vierge du Rosaire"
      end
    end
  end

  describe "updates" do
    context "some updates" do
      let!(:persisted_objet) do
        create(
          :objet,
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
      let(:row) do
        {
          "REF" => persisted_objet.palissy_REF,
          "DENO" => ["tableau bleu"],
          "CATE" => ["peinture"],
          "COM" => "Ambérieu-en-Bugey",
          "INSEE" => "01004",
          "DPT" => "01",
          "SCLE" => ["1er quart 18e siècle"],
          "DENQ" => nil,
          "DOSS" => "sous-dossier",
          "EDIF" => "chapelle des Allymes",
          "EMPL" => "chapelle située au milieu du cimetière",
          "TICO" => "Tableau super grand"
        }
      end
      let(:objet_builder) { described_class.new(row, persisted_objet:) }
      it "be marked to update" do
        expect(objet_builder.can_update?).to eq true
        expect(objet_builder.objet_with_updates.changes).to eq(
          {
            "palissy_DENO" => ["tableau", "tableau bleu"],
            "palissy_SCLE" => [nil, "1er quart 18e siècle"],
            "palissy_DOSS" => ["dossier individuel", "sous-dossier"],
            "palissy_TICO" => ["Tableau : Vierge du Rosaire", "Tableau super grand"],
            "palissy_DENQ" => ["2001", nil]
          }
        )
        expect(objet_builder.objet_with_updates.palissy_DENO).to eq "tableau bleu"
        expect(objet_builder.objet_with_updates.palissy_SCLE).to eq "1er quart 18e siècle"
        expect(objet_builder.objet_with_updates.palissy_DOSS).to eq "sous-dossier"
        expect(objet_builder.objet_with_updates.palissy_TICO).to eq "Tableau super grand"
        expect(objet_builder.objet_with_updates.palissy_DENQ).to eq nil
      end
    end

    context "no updates" do
      let!(:persisted_objet) do
        create(
          :objet,
          palissy_DENO: "tableau",
          palissy_CATE: "peinture",
          palissy_COM: "Ambérieu-en-Bugey",
          palissy_INSEE: "01004",
          palissy_DPT: "01",
          palissy_SCLE: nil,
          palissy_DENQ: nil,
          palissy_DOSS: "dossier individuel",
          palissy_EDIF: "chapelle des Allymes",
          palissy_EMPL: "chapelle située au milieu du cimetière",
          palissy_TICO: "Tableau : Vierge du Rosaire"
        )
      end
      let(:row) do
        {
          "REF" => persisted_objet.palissy_REF,
          "DENO" => ["tableau"],
          "CATE" => ["peinture"],
          "COM" => "Ambérieu-en-Bugey",
          "INSEE" => "01004",
          "DPT" => "01",
          "SCLE" => [],
          "DENQ" => nil,
          "DOSS" => "dossier individuel",
          "EDIF" => "chapelle des Allymes",
          "EMPL" => "chapelle située au milieu du cimetière",
          "TICO" => "Tableau : Vierge du Rosaire"
        }
      end
      let(:objet_builder) { described_class.new(row, persisted_objet:) }
      it "be marked to update" do
        expect(objet_builder.can_update?).to eq true
        expect(objet_builder.objet_with_updates.changes).to be_empty
        expect(objet_builder.objet_with_updates.changed?).to eq false
      end
    end
  end
end

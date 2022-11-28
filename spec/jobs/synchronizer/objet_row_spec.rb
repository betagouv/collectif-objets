# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::ObjetRow do
  let(:raw_row_base) do
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
  let(:commune_inactive) do
    build(:commune, nom: "Amberieu en bugey", code_insee: "01004", departement_code: "01", status: :inactive)
  end

  context "nouvel objet" do
    context "simple" do
      let(:row) { described_class.new(raw_row_base, commune: commune_inactive) }
      it "should be valid" do
        expect(row.valid?).to eq(true)
        expect(row.action).to eq(:create)
        expect(row.objet.palissy_REF).to eq("PM01000001")
        expect(row.objet.palissy_DENO).to eq "tableau"
        expect(row.objet.palissy_CATE).to eq "peinture"
        expect(row.objet.palissy_COM).to eq "Ambérieu-en-Bugey"
        expect(row.objet.palissy_INSEE).to eq "01004"
        expect(row.objet.palissy_DPT).to eq "01"
        expect(row.objet.palissy_SCLE).to eq "1er quart 17e siècle"
        expect(row.objet.palissy_DENQ).to eq "2001"
        expect(row.objet.palissy_DOSS).to eq "dossier individuel"
        expect(row.objet.palissy_EDIF).to eq "chapelle des Allymes"
        expect(row.objet.palissy_EMPL).to eq "chapelle située au milieu du cimetière"
        expect(row.objet.palissy_TICO).to eq "Tableau : Vierge du Rosaire"
      end
    end

    context "TICO en cours de traitement" do
      let(:raw_row) do
        raw_row_base.merge("TICO" => "Traitement en cours")
      end
      let(:row) { described_class.new(raw_row, commune: commune_inactive) }
      it "should not be valid" do
        expect(row.valid?).to eq false
        expect(row.action).to eq(:create_invalid)
        expect(row.log_message).to match(/l'objet est en cours de traitement/)
      end
    end

    context "commune est active" do
      let(:commune) { build(:commune, status: :started) }
      let(:row) { described_class.new(raw_row_base, commune:) }
      it "should not be valid" do
        expect(row.valid?).to eq false
        expect(row.action).to eq(:create_invalid)
        expect(row.log_message).to match(/la commune .* est started/)
      end
    end

    context "commune manquante" do
      it "should raise" do
        expect { described_class.new(raw_row_base, commune: nil).valid? }.to raise_error(StandardError)
      end
    end
  end

  context "objet mis a jour" do
    context "quelques modifs" do
      let!(:persisted_objet) do
        create(
          :objet,
          commune: commune_inactive,
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
      let(:raw_row) do
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
      let(:row) { described_class.new(raw_row, commune: commune_inactive, persisted_objet:) }
      it "be marked to update" do
        expect(row.valid?).to eq true
        expect(row.action).to eq :update
        expect(row.objet.changes).to eq(
          {
            "palissy_DENO" => ["tableau", "tableau bleu"],
            "palissy_SCLE" => [nil, "1er quart 18e siècle"],
            "palissy_DOSS" => ["dossier individuel", "sous-dossier"],
            "palissy_TICO" => ["Tableau : Vierge du Rosaire", "Tableau super grand"],
            "palissy_DENQ" => ["2001", nil]
          }
        )
        expect(row.log_message).to match(/tableau bleu/)
        expect(row.objet.palissy_DENO).to eq "tableau bleu"
        expect(row.objet.palissy_SCLE).to eq "1er quart 18e siècle"
        expect(row.objet.palissy_DOSS).to eq "sous-dossier"
        expect(row.objet.palissy_TICO).to eq "Tableau super grand"
        expect(row.objet.palissy_DENQ).to eq nil
      end
    end

    context "no updates" do
      let!(:persisted_objet) do
        create(
          :objet,
          commune: commune_inactive,
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
      let(:raw_row) do
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
      let(:row) { described_class.new(raw_row, commune: commune_inactive, persisted_objet:) }
      it "should not change" do
        expect(row.valid?).to eq true
        expect(row.action).to eq :not_changed
        expect(row.objet.changes).to be_empty
        expect(row.objet.changed?).to eq false
      end
    end

    context "commune initiale active" do
      let(:commune) do
        build(:commune, nom: "Amberieu en bugey", code_insee: "01004", departement_code: "01", status: :started)
      end
      let!(:persisted_objet) do
        create(
          :objet,
          commune:,
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
        let(:row) { described_class.new(raw_row_base, commune:, persisted_objet:) }
        it "should not change" do
          expect(row.valid?).to eq true
          expect(row.action).to eq :not_changed
          expect(row.objet.changes).to be_empty
          expect(row.objet.changed?).to eq false
        end
      end

      context "minor changes" do
        let(:raw_row) { raw_row_base.merge("DENQ" => ["2002"]) }
        let(:row) { described_class.new(raw_row, commune:, persisted_objet:) }
        it "should update" do
          expect(row.valid?).to eq true
          expect(row.action).to eq :update
          expect(row.objet.changes).to eq({ "palissy_DENQ" => %w[2001 2002] })
          expect(row.objet.changed?).to eq true
        end
      end

      context "major changes" do
        let(:raw_row) { raw_row_base.merge({ "DENQ" => ["2002"], "DENO" => ["mega tableau"] }) }
        let(:row) { described_class.new(raw_row, commune:, persisted_objet:) }
        it "should not change" do
          expect(row.valid?).to eq false
          expect(row.action).to eq :update_invalid
          expect(row.objet.changes).to eq(
            {
              "palissy_DENQ" => %w[2001 2002],
              "palissy_DENO" => ["tableau", "mega tableau"]
            }
          )
          expect(row.objet.changed?).to eq true
        end
      end
    end

    context "changement de commune depuis inactive vers autre inactive avec des changements importants" do
      let!(:persisted_objet) do
        create(
          :objet,
          commune: build(
            :commune,
            nom: "Amberieu en bugey", code_insee: "01004", departement_code: "01",
            status: :inactive
          ),
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
      let!(:commune2) { create(:commune, status: :inactive, code_insee: "02003", nom: "Marcopolis") }
      let(:raw_row) do
        raw_row_base.merge(
          {
            "INSEE" => "02003",
            "DPT" => "02",
            "palissy_DENO" => "joli tableau"
          }
        )
      end
      let(:row) { described_class.new(raw_row, commune: commune2, persisted_objet:) }
      it "should update" do
        expect(row.valid?).to eq true
        expect(row.action).to eq :update
        expect(row.objet.commune).to eq(commune2)
        expect(row.objet.changed?).to eq true
      end
    end

    context "changement de commune depuis inactive vers started avec des changements importants" do
      let!(:persisted_objet) do
        create(
          :objet,
          commune: build(
            :commune,
            nom: "Amberieu en bugey", code_insee: "01004", departement_code: "01",
            status: :inactive
          ),
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
      let!(:commune2) { create(:commune, status: :started, code_insee: "02003", nom: "Marcopolis") }
      let(:raw_row) do
        raw_row_base.merge(
          {
            "INSEE" => "02003",
            "DPT" => "02",
            "palissy_DENO" => "joli tableau"
          }
        )
      end
      let(:row) { described_class.new(raw_row, commune: commune2, persisted_objet:) }
      it "should not update" do
        expect(row.valid?).to eq false
        expect(row.action).to eq :update_invalid
        expect(row.objet.commune).to eq(commune2)
        expect(row.objet.changed?).to eq true
        expect(row.log_message).to match(/la commune .* est started/)
      end
    end

    context "changement de commune depuis started vers inactive avec des changements importants" do
      let!(:persisted_objet) do
        create(
          :objet,
          commune: build(
            :commune,
            nom: "Amberieu en bugey", code_insee: "01004", departement_code: "01",
            status: :started
          ),
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
      let!(:commune2) { create(:commune, status: :inactive, code_insee: "02003", nom: "Marcopolis") }
      let(:raw_row) do
        raw_row_base.merge(
          {
            "INSEE" => "02003",
            "DPT" => "02",
            "palissy_DENO" => "joli tableau"
          }
        )
      end
      let(:row) { described_class.new(raw_row, commune: commune2, persisted_objet:) }
      it "should not update" do
        expect(row.valid?).to eq false
        expect(row.action).to eq :update_invalid
        expect(row.objet.changed?).to eq true
        expect(row.log_message).to match(/la commune initiale .* est started/)
      end
    end
  end
end

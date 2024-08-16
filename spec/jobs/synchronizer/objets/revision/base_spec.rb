# frozen_string_literal: true

require "rails_helper"

RSpec.describe Synchronizer::Objets::Revision::Base do
  let(:row) { instance_double(Synchronizer::Objets::Row, in_scope?: true, out_of_scope?: false) }
  let(:objet_attributes) do
    {
      palissy_REF: "PM01000001",
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
      palissy_REFA: nil,
      palissy_DPRO: "2007/01/29 : classé au titre objet",
      palissy_PROT: "classé au titre objet",
      palissy_WEB: nil,
      palissy_MOSA: nil,
      palissy_DEPL: nil,
      lieu_actuel_code_insee: "01004",
      lieu_actuel_edifice_nom: "chapelle des Allymes",
      lieu_actuel_edifice_ref: nil
    }
  end
  let(:logger) { instance_double(Synchronizer::Logger) }

  context "insertion" do
    let(:eager_loaded_records) do
      instance_double(
        Synchronizer::Objets::Batch::EagerLoadedRecords,
        commune:,
        objet: nil,
        edifice_by_ref: nil,
        edifice_by_code_insee_and_slug: nil
      )
    end

    context "commune inactive" do
      let!(:commune) { create(:commune, code_insee: "01004", status: :inactive) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "créé l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :create)
        expect(revision.synchronize).to eq true
        expect(revision.objet.palissy_REF).to eq "PM01000001"
        expect(revision.objet.palissy_DENO).to eq "tableau"
      end
    end

    context "commune en cours de recensement" do
      let(:commune) { build(:commune, code_insee: "01004", status: :started) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "créé l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :create)
        expect(revision.synchronize).to eq true
        expect(revision.objet.palissy_REF).to eq "PM01000001"
        expect(revision.objet.palissy_DENO).to eq "tableau"
      end
    end

    context "commune a terminé son recensement" do
      let(:commune) { build(:commune, code_insee: "01004", status: :completed) }
      let!(:dossier) { create(:dossier, :submitted, commune:) }
      before { commune.update!(dossier:) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "créé l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :create)
        expect(revision.synchronize).to eq true
        expect(revision.objet.palissy_REF).to eq "PM01000001"
        expect(revision.objet.palissy_DENO).to eq "tableau"
      end
    end

    context "commune a terminé son recensement mais son dossier a été accepté" do
      let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
      let!(:dossier) { create(:dossier, :accepted, commune:, conservateur: create(:conservateur)) }
      before { commune.update!(dossier:) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "créé l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :create)
        expect(revision.synchronize).to eq true
        expect(revision.objet.palissy_REF).to eq "PM01000001"
        expect(revision.objet.palissy_DENO).to eq "tableau"
      end
    end

    describe "edifice handling" do
      context "1 ref Mérimée est passée et ne correspond à aucun édifice existant" do
        let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
        before do
          objet_attributes[:palissy_REFA] = "PA00113792"
          objet_attributes[:lieu_actuel_edifice_ref] = "PA00113792"
        end
        let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
        it "créé un nouvel édifice" do
          expect(Edifice.count).to eq 0
          expect(logger).to receive(:log).with(any_args, counter: :create)
          expect(revision.synchronize).to eq true
          expect(Edifice.count).to eq 1
          edifice = Edifice.first
          expect(revision.objet.edifice).to eq edifice
          expect(edifice.merimee_REF).to eq "PA00113792"
          expect(edifice.code_insee).to eq "01004"
          expect(edifice.nom).to eq "chapelle des Allymes"
          expect(edifice.slug).to eq "chapelle-des-allymes"
        end
      end

      context "1 ref Mérimée correspondant à un édifice existant dans CO qui appartient à la bonne commune" do
        let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
        before do
          objet_attributes[:palissy_REFA] = "PA00113792"
          objet_attributes[:lieu_actuel_edifice_ref] = "PA00113792"
        end
        let!(:edifice) { create(:edifice, merimee_REF: "PA00113792", code_insee: "01004", nom: "Montmir") }
        before { allow(eager_loaded_records).to receive(:edifice_by_ref).and_return(edifice) }
        let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
        it "associe l’objet à l’édifice existant" do
          expect(Edifice.count).to eq 1
          expect(logger).to receive(:log).with(any_args, counter: :create)
          expect(revision.synchronize).to eq true
          expect(Edifice.count).to eq 1
          expect(revision.objet.edifice).to eq edifice
          expect(edifice.reload.nom).to eq "Montmir"
        end
      end

      context "1 ref Mérimée correspondant à un édifice existant dans CO mais qui appartient à une autre commune" do
        let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
        before do
          objet_attributes[:palissy_REFA] = "PA00113792"
          objet_attributes[:lieu_actuel_edifice_ref] = "PA00113792"
        end
        let!(:edifice) { create(:edifice, merimee_REF: "PA00113792", code_insee: "01005", nom: "Montmir") }
        before { allow(eager_loaded_records).to receive(:edifice_by_ref).and_return(edifice) }
        let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
        it "n’utilise pas l’édifice existant mais en créé un nouveau sans ref" do
          expect(Edifice.count).to eq 1
          expect(logger).to receive(:log).with(any_args, counter: :create)
          expect(revision.synchronize).to eq true
          expect(Edifice.count).to eq 2
          expect(revision.objet.edifice.merimee_REF).to be_nil
          expect(revision.objet.edifice.code_insee).to eq "01004"
          expect(revision.objet.edifice.nom).to eq "chapelle des Allymes"
          expect(revision.objet.edifice.slug).to eq "chapelle-des-allymes"
        end
      end

      context "aucune ref Mérimée dans Palissy et aucun ne correspond dans CO" do
        let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
        let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
        before do
          objet_attributes.merge(
            palissy_INSEE: "01004",
            palissy_EDIF: "eglise de montmirail",
            palissy_REFA: nil,
            lieu_actuel_code_insee: "01004",
            lieu_actuel_edifice_ref: nil,
            lieu_actuel_edifice_nom: "eglise de montmirail"
          )
        end
        it "créé un nouvel édifice et l’utilise" do
          expect(Edifice.count).to eq 0
          expect(logger).to receive(:log).with(any_args, counter: :create)
          expect(revision.synchronize).to eq true
          expect(Edifice.count).to eq 1
          edifice = Edifice.first
          expect(revision.objet.edifice).to eq edifice
          expect(edifice.merimee_REF).to be_nil
          expect(edifice.code_insee).to eq "01004"
          expect(edifice.nom).to eq "chapelle des Allymes"
          expect(edifice.slug).to eq "chapelle-des-allymes"
        end
      end

      context "aucune ref Mérimée dans Palissy et un édifice correspond dans CO" do
        let!(:commune) { create(:commune, code_insee: "01004", status: :completed) }
        before do
          objet_attributes.merge(
            palissy_INSEE: "01004",
            palissy_EDIF: "eglise de montmirail",
            palissy_REFA: nil,
            lieu_actuel_code_insee: "01004",
            lieu_actuel_edifice_ref: nil,
            lieu_actuel_edifice_nom: "eglise de montmirail"
          )
        end
        let!(:edifice) { create(:edifice, code_insee: "01004", slug: "eglise-montmirail", nom: "Montmir") }
        before { allow(eager_loaded_records).to receive(:edifice_by_code_insee_and_slug).and_return(edifice) }
        let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
        it "réutilise l’édifice sans REF existant" do
          expect(Edifice.count).to eq 1
          expect(logger).to receive(:log).with(any_args, counter: :create)
          expect(revision.synchronize).to eq true
          expect(Edifice.count).to eq 1
          expect(revision.objet.edifice).to eq edifice
          expect(edifice.reload.nom).to eq "Montmir"
        end
      end
    end
  end

  context "existing objet" do
    let!(:persisted_edifice) do
      create(
        :edifice,
        commune: commune_before_update,
        nom: "chapelle des Allymes",
        slug: "chapelle-des-allymes"
      )
    end

    let!(:persisted_objet) do
      create(
        :objet,
        edifice: persisted_edifice,
        commune: commune_before_update,
        palissy_REF: "PM01000001",
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
        palissy_PROT: "classé au titre objet",
        palissy_WEB: nil,
        palissy_MOSA: nil,
        palissy_DEPL: nil,
        lieu_actuel_code_insee: "01004",
        lieu_actuel_edifice_nom: "chapelle des Allymes",
        lieu_actuel_edifice_ref: nil
      )
    end

    let(:eager_loaded_records) do
      instance_double(
        Synchronizer::Objets::Batch::EagerLoadedRecords,
        objet: persisted_objet,
        edifice_by_ref: nil,
        edifice_by_code_insee_and_slug: persisted_edifice
      )
    end

    context "aucun changement" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_before_update) }
      it "ne fait rien" do
        expect(revision.objet.changes).to be_empty
        expect(logger).to receive(:log).with(any_args, counter: :not_changed)
        expect(revision.synchronize).to eq true
      end
    end

    context "quelques changements sûrs" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_before_update) }
      before do
        objet_attributes.merge!(
          palissy_DENO: "tableau bleu",
          palissy_SCLE: "1er quart 18e siècle",
          palissy_DOSS: "sous-dossier",
          palissy_TICO: "Tableau super grand",
          palissy_DENQ: nil
        )
      end
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "met à jour l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :update)
        expect(revision.synchronize).to eq true
        expect(revision.objet.reload.palissy_DENO).to eq "tableau bleu"
        expect(revision.objet.reload.palissy_SCLE).to eq "1er quart 18e siècle"
        expect(revision.objet.reload.palissy_DOSS).to eq "sous-dossier"
        expect(revision.objet.reload.palissy_TICO).to eq "Tableau super grand"
      end
    end

    context "commune en cours de recensement + aucun changement" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_before_update) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "ne fait rien" do
        expect(logger).to receive(:log).with(any_args, counter: :not_changed)
        expect(revision.synchronize).to eq true
      end
    end

    context "commune en cours de recensement + changements sûrs" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :started) }
      before { objet_attributes.merge!(palissy_DENQ: "2021") }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_before_update) }
      it "met à jour" do
        expect(logger).to receive(:log).with(any_args, counter: :update)
        expect(revision.synchronize).to eq true
        expect(revision.objet.reload.palissy_DENQ).to eq "2021"
      end
    end

    context "changement de commune + objet déjà recensé" do
      let!(:commune_before_update) { create(:commune_en_cours_de_recensement, code_insee: "01004") }
      let!(:recensement) { create(:recensement, objet: persisted_objet, dossier: commune_before_update.dossier) }
      let!(:commune_after_update) { create(:commune_en_cours_de_recensement, code_insee: "01999") }
      before do
        objet_attributes.merge!(
          palissy_INSEE: "01999",
          palissy_COM: "Nogent",
          palissy_EDIF: "Église st-Jean",
          palissy_EMPL: "au fond à gauche",
          palissy_TICO: "Rosarium",
          lieu_actuel_code_insee: "01999",
          lieu_actuel_edifice_nom: "Église st-Jean"
        )
      end
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_after_update) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "change l’objet de commune et soft-delete le recensement" do
        expect(logger).to receive(:log).with(any_args, counter: :update_with_commune_change_recensement_deleted)
        expect(revision.synchronize).to eq true
        expect(revision.objet.reload.palissy_INSEE).to eq("01999")
        expect(revision.objet.reload.palissy_EDIF).to eq("Église st-Jean")
        expect(revision.objet.reload.palissy_EMPL).to eq("au fond à gauche")
        expect(recensement.reload.deleted?).to eq true
        expect(recensement.reload.deleted_reason).to eq "changement-de-commune"
        expect(recensement.reload.deleted_message).to \
          eq "changement de commune appliqué Châlons-en-Champagne (01004) → Châlons-en-Champagne (01999)"
      end
    end

    context "changement de commune mais objet jamais recensé" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :inactive) }
      before do
        objet_attributes.merge!(
          palissy_INSEE: "01999",
          palissy_COM: "Nogent",
          palissy_EDIF: "Église st-Jean",
          palissy_EMPL: "au fond à gauche",
          palissy_TICO: "Rosarium",
          lieu_actuel_code_insee: "01999",
          lieu_actuel_edifice_nom: "Église st-Jean"
        )
      end
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_after_update) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "change la commune et met à jour les champs" do
        expect(logger).to receive(:log).with(any_args, counter: :update_with_commune_change)
        expect(revision.synchronize).to eq true
        expect(revision.objet.reload.palissy_INSEE).to eq("01999")
        expect(revision.objet.reload.palissy_COM).to eq("Nogent")
        expect(revision.objet.reload.palissy_EDIF).to eq("Église st-Jean")
        expect(revision.objet.reload.palissy_EMPL).to eq("au fond à gauche")
        expect(revision.objet.reload.palissy_TICO).to eq("Rosarium")
      end
    end

    context "changement de commune mais objet jamais recensé, commune destinataire en cours de recensement" do
      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      let!(:commune_after_update) { create(:commune, code_insee: "01999", status: :started) }
      before do
        objet_attributes.merge!(
          palissy_INSEE: "01999",
          palissy_COM: "Nogent",
          palissy_EDIF: "Église st-Jean",
          palissy_EMPL: "au fond à gauche",
          palissy_TICO: "Rosarium",
          lieu_actuel_code_insee: "01999",
          lieu_actuel_edifice_nom: "Église st-Jean"
        )
      end
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_after_update) }
      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }
      it "change pas la commune et met à jour les champs" do
        expect(logger).to receive(:log).with(any_args, counter: :update_with_commune_change)
        expect(revision.synchronize).to eq true
        expect(revision.objet.reload.palissy_INSEE).to eq("01999")
        expect(revision.objet.reload.palissy_COM).to eq("Nogent")
        expect(revision.objet.reload.palissy_EDIF).to eq("Église st-Jean")
        expect(revision.objet.reload.palissy_EMPL).to eq("au fond à gauche")
        expect(revision.objet.reload.palissy_TICO).to eq("Rosarium")
      end
    end

    context "objet devient hors-scope" do
      let(:row) do
        instance_double(
          Synchronizer::Objets::Row,
          in_scope?: false,
          out_of_scope?: true,
          out_of_scope_message: "la notice n’a pas de code INSEE"
        )
      end

      let(:revision) { described_class.new(row:, objet_attributes:, eager_loaded_records:, logger:) }

      let!(:commune_before_update) { create(:commune, code_insee: "01004", status: :inactive) }
      before { allow(eager_loaded_records).to receive(:commune).and_return(commune_before_update) }

      it "supprime l’objet" do
        expect(logger).to receive(:log).with(any_args, counter: :destroy)
        expect(persisted_objet).to \
          receive(:destroy_and_soft_delete_recensement!)
            .with(
              reason: "objet-devenu-hors-scope",
              message: "la notice n’a pas de code INSEE",
              objet_snapshot: {
                "lieu_actuel_code_insee" => "01004",
                "lieu_actuel_edifice_nom" => "chapelle des Allymes",
                "palissy_REF" => "PM01000001",
                "palissy_TICO" => "Tableau : Vierge du Rosaire"
              }
            )
        expect(revision.synchronize).to eq true
      end
    end
  end
end

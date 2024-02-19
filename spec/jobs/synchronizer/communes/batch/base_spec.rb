# frozen_string_literal: true

require "rails_helper"

module Synchronizer
  module Communes
    # Ces tests sont moyennement agréables à lire, ils stubbent beaucoup de dépendances.
    # Ils sont cependant indispensables pour vérifier que seules les lignes pertinents sont synchronisées.
    describe Batch::Base do
      context "panaché de lignes" do
        let(:csv_row_new_commune) { { "code_insee_commune" => "01001" } }
        let(:csv_row_out_of_scope) { { "code_insee_commune" => "02001" } }
        let(:csv_row_0_objets) { { "code_insee_commune" => "03001" } }
        let(:csv_row_existing_commune) { { "code_insee_commune" => "97201" } }

        let(:parsed_row_new_commune) { { commune: { code_insee: "01001" }, user: {} } }
        # no parsed row for 02001 because it will be out of scope
        let(:parsed_row_0_objets) { { commune: { code_insee: "03001" }, user: {} } }
        let(:parsed_row_existing_commune) { { commune: { code_insee: "97201" }, user: {} } }

        let(:row_new_commune) { instance_double(Row, in_scope?: true) }
        let(:row_out_of_scope) { instance_double(Row, in_scope?: false) }
        let(:row_0_objets) { instance_double(Row, in_scope?: true) }
        let(:row_existing_commune) { instance_double(Row, in_scope?: true) }

        let(:revision_new_commune) { instance_double(Revision) }
        let(:revision_existing_commune) { instance_double(Revision) }

        let!(:commune97201) { create(:commune, nom: "Fort de france", code_insee: "97201") }

        before do
          create(:objet, lieu_actuel_code_insee: "01001", commune: nil)
          create(:objet, lieu_actuel_code_insee: "02001", commune: nil)
          create(:objet, lieu_actuel_code_insee: "97201", commune: commune97201)
        end

        it "works" do
          batch = Batch::Base.new(
            [csv_row_new_commune, csv_row_out_of_scope, csv_row_0_objets, csv_row_existing_commune]
          )

          expect(Row).to receive(:new).with(csv_row_new_commune).and_return(row_new_commune)
          expect(Row).to receive(:new).with(csv_row_out_of_scope).and_return(row_out_of_scope)
          expect(Row).to receive(:new).with(csv_row_0_objets).and_return(row_0_objets)
          expect(Row).to receive(:new).with(csv_row_existing_commune).and_return(row_existing_commune)

          expect(batch).to receive(:parse_row_to_commune_and_user_attributes)
            .with(row_new_commune).and_return(parsed_row_new_commune)
          expect(batch).to receive(:parse_row_to_commune_and_user_attributes)
            .with(row_0_objets).and_return(parsed_row_0_objets)
          expect(batch).to receive(:parse_row_to_commune_and_user_attributes)
            .with(row_existing_commune).and_return(parsed_row_existing_commune)

          expect(Revision).to receive(:new)
            .with(parsed_row_new_commune, persisted_commune: nil, logger: nil)
            .and_return(revision_new_commune)
          expect(Revision).to receive(:new)
            .with(parsed_row_existing_commune, persisted_commune: commune97201, logger: nil)
            .and_return(revision_existing_commune)

          expect(revision_new_commune).to receive(:synchronize)
          expect(revision_existing_commune).to receive(:synchronize)

          expect(batch.revisions.count).to eq 2
          batch.synchronize
        end
      end
    end

    context "if_block limits to destroys" do
      let(:csv_row_destroy_user) { { "code_insee_commune" => "01001" } }
      let(:csv_row_no_destroy) { { "code_insee_commune" => "02001" } }

      let(:parsed_row_destroy_user) { { commune: { code_insee: "01001" }, user: {} } }
      let(:parsed_row_no_destroy) { { commune: { code_insee: "02001" }, user: {} } }

      let(:row_destroy_user) { instance_double(Row, in_scope?: true) }
      let(:row_no_destroy) { instance_double(Row, in_scope?: true) }

      let(:revision_destroy_user) { instance_double(Revision, destroy_user?: true) }
      let(:revision_no_destroy) { instance_double(Revision, destroy_user?: false) }

      let!(:commune01001) { create(:commune, nom: "Bourg en bresse", code_insee: "01001") }
      let!(:commune02001) { create(:commune, nom: "Macon", code_insee: "02001") }

      before do
        create(:objet, lieu_actuel_code_insee: "01001", commune: commune01001)
        create(:objet, lieu_actuel_code_insee: "02001", commune: commune02001)
      end

      it "only the revision that destroys a user is ran" do
        batch = Batch::Base.new [csv_row_destroy_user, csv_row_no_destroy]

        expect(Row).to receive(:new).with(csv_row_destroy_user).and_return(row_destroy_user)
        expect(Row).to receive(:new).with(csv_row_no_destroy).and_return(row_no_destroy)

        expect(batch).to receive(:parse_row_to_commune_and_user_attributes)
          .with(row_destroy_user).and_return(parsed_row_destroy_user)
        expect(batch).to receive(:parse_row_to_commune_and_user_attributes)
          .with(row_no_destroy).and_return(parsed_row_no_destroy)

        expect(Revision).to receive(:new)
          .with(parsed_row_destroy_user, persisted_commune: commune01001, logger: nil)
          .and_return(revision_destroy_user)
        expect(Revision).to receive(:new)
          .with(parsed_row_no_destroy, persisted_commune: commune02001, logger: nil)
          .and_return(revision_no_destroy)

        expect(revision_destroy_user).to receive(:synchronize)
        expect(revision_no_destroy).not_to receive(:synchronize)

        expect(batch.revisions.count).to eq 2
        batch.synchronize(if_block: ->(revision) { revision.destroy_user? })
      end
    end
  end
end

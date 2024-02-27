# frozen_string_literal: true

require "rails_helper"

module Synchronizer
  module Communes
    # Ce test était dur à écrire et sera probablement dur à lire, il stubbe quasiment tout ce que fait le job.
    # Je vois quand même un petit intérêt à vérifier qu’on exclue bien les communes dont le code insee
    # est présent plusieurs fois dans le CSV qui vient de l’API de l’annuaire de l’administration
    # Pistes d’amélioration :
    # - supprimer ce test
    # - extraire la partie excluant les communes avec plusieurs mairies principales et la tester
    describe SynchronizeAllJob do
      let(:csv_rows) do
        rows_code_insees.map { |code_insee| { "code_insee_commune" => code_insee } }
      end
      let(:rows) do
        rows_code_insees.zip(rows_in_scope).map do |code_insee, in_scope|
          instance_double(Row, out_of_scope?: !in_scope, in_scope?: in_scope, code_insee:)
        end
      end
      let(:logger) { instance_double(Synchronizer::Logger, log: nil, close: nil) }
      let(:api_client) { instance_double(ApiClientAnnuaireAdministration, count_all: csv_rows.count) }
      let(:batch) { instance_double(Batch::Base, skipped_rows_count: 0) }

      before do
        expect(ApiClientAnnuaireAdministration).to receive(:new).and_return(api_client)
        expect(api_client).to receive(:each) do |&block|
          csv_rows.each { block.call(_1) }
        end
        expect(api_client).to receive(:each_slice).at_least(:once).and_yield(csv_rows)
        csv_rows.count.times do |i|
          allow(Row).to receive(:new).at_least(:once).with(csv_rows[i]).and_return(rows[i])
        end
        expect(Synchronizer::Logger).to receive(:new).and_return(logger)
        expect(batch).to receive(:synchronize).with(if_block: anything).twice
      end

      context "simple case" do
        let(:rows_code_insees) { %w[01002 03001 97201] }
        let(:rows_in_scope) { [true, true, true] }
        it "should work" do
          expect(Batch::Base).to receive(:new).exactly(:twice).with(csv_rows, logger:).and_return(batch)
          SynchronizeAllJob.new.perform
        end
      end

      context "when there are multiple mairies principales for a single code insee" do
        let(:rows_code_insees) { %w[01002 03001 97201 97201 13001] }
        let(:rows_in_scope) { [true, true, true, true, true] }
        it "should exclude these lines" do
          expect(Batch::Base).to \
            receive(:new).exactly(:twice).with([csv_rows[0], csv_rows[1], csv_rows[4]], logger:).and_return(batch)
          SynchronizeAllJob.new.perform
        end
      end

      context "when there are multiple rows for a single code insee but one is out of scope" do
        let(:rows_code_insees) { %w[01002 03001 97201 97201 13001] }
        let(:rows_in_scope) { [true, true, true, false, true] }
        it "should not exclude the duplicate rows, the batch will exclude the out of scope one itself" do
          expect(Batch::Base).to \
            receive(:new)
              .exactly(:twice)
              .with(csv_rows, logger:)
              .and_return(batch)
          SynchronizeAllJob.new.perform
        end
      end
    end
  end
end

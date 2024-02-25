# frozen_string_literal: true

module Synchronizer
  module Communes
    class SynchronizeAllJob < ApplicationJob
      BATCH_SIZE = 1000

      def perform
        Rails.logger.info("starting iteration by batch of #{BATCH_SIZE}...")
        create_progressbar
        # La synchronisation des communes nécessite trois parcours consécutifs du CSV :
        cycle_1_set_code_insees_with_multiple_mairies
        cycle_2_destroy_users_with_disappeared_email
        cycle_3_upsert_all
        logger.close
      end

      private

      def create_progressbar
        return if Rails.env.test?

        @progressbar = ProgressBar.create(total: client.count_all * 3, format: "%t: |%B| %p%% %e %c/%u")
      end

      def logger
        @logger ||= Synchronizer::Logger.new(filename_prefix: "synchronize-communes")
      end

      def client
        @client ||= ApiClientAnnuaireAdministration.new
      end

      def cycle_1_set_code_insees_with_multiple_mairies
        # identifie les codes INSEE avec plusieurs mairies principales
        @code_insees_with_multiple_mairies = begin
          logger.log "searching for code insees with multiple mairies principales..."
          counts = Hash.new(0)
          client.each do |csv_row|
            @progressbar&.increment
            row = Row.new(csv_row)
            next if row.out_of_scope?

            counts[row.code_insee] += 1
          end
          codes = counts.select { |_code, count| count > 1 }.map(&:first)
          logger.log "found #{codes.count} codes insees that match multiple mairies principales : #{codes}"
          codes
        end
      end

      def cycle_2_destroy_users_with_disappeared_email
        # supprimer les Users dont l’email a disparu dans le CSV
        # extraire ce cycle du 3ème permet de libérer les emails qui peuvent être réutilisés
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1, if_block: ->(revision) { revision.destroy_user? }) }
      end

      def cycle_3_upsert_all
        # upsert toutes les communes et Users
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1) }
      end

      def synchronize_batch(csv_rows, if_block: nil)
        excluded, included = csv_rows
          .partition { @code_insees_with_multiple_mairies.include?(_1["code_insee_commune"]) }

        batch = Batch::Base.new(included, logger:)
        batch.synchronize(if_block:) { @progressbar&.increment }
        (excluded.count + batch.skipped_rows_count).times { @progressbar&.increment }
      end
    end
  end
end

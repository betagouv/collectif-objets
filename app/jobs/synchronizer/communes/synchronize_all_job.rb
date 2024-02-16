# frozen_string_literal: true

module Synchronizer
  module Communes
    # La synchronisation des communes nécessite trois parcours consécutifs du CSV :
    # 1. le premier pour identifier les codes INSEE avec plusieurs mairies principales
    # 2. le second pour supprimer les Users dont l’email a disparu dans le CSV
    # 3. le troisième pour upsert toutes les communes et Users
    # L’étape 2. permet de libérer les emails des Users supprimés pour qu’ils soient potentiellement
    # réutilisés à l’étape 3
    class SynchronizeAllJob < ApplicationJob
      BATCH_SIZE = 1000

      def perform
        Rails.logger.info("starting iteration by batch of #{BATCH_SIZE}...")
        create_progressbar
        set_code_insees_with_multiple_mairies
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1, if_block: ->(revision) { revision.destroy_user? }) }
        client.each_slice(BATCH_SIZE) { synchronize_batch(_1) } # rubocop:disable Style/CombinableLoops
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

      def set_code_insees_with_multiple_mairies
        @code_insees_with_multiple_mairies = begin
          logger.log "searching for code insees with multiple mairies principales..."
          counts = Hash.new(0)
          client.each do |csv_row|
            @progressbar&.increment
            row = Row.new(csv_row)
            next if row.invalid?

            counts[row["code_insee_commune"]] += 1
          end
          codes = counts.select { |_code, count| count > 1 }.map(&:first)
          logger.log "found #{codes.count} codes insees that match multiple mairies principales : #{codes}"
          codes
        end
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

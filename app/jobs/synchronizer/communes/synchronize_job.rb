# frozen_string_literal: true

module Synchronizer
  module Communes
    class SynchronizeJob
      include Sidekiq::Job

      BATCH_SIZE = 1000

      def perform
        Rails.logger.info("starting iteration by batch of #{BATCH_SIZE}...")
        @progressbar = ProgressBar.create(total: client.count_all, format: "%t: |%B| %p%% %e %c/%u")
        client.each_slice(BATCH_SIZE) { synchronize_batch(batch) }

        return if revisions_for_code_insees_with_multiple_communes.empty?

        Rails.logger.info(
          "iterating #{revisions_for_code_insees_with_multiple_communes} revisions" \
          "for code insees with multiple communes..."
        )
        revisions_for_code_insees_with_multiple_communes.each(&:synchronize)
      end

      private

      def synchronize_batch(batch)
        revisions = batch
          .map { Revision.new(_1) }
          .select { _1.mairie? && !_1.mairie_annexe? }
          .select { code_insees_with_multiple_mairies.exclude?(_1.code_insee) }

        communes_by_code_insee = Commune
          .joins(:objets)
          .where(code_insee: revisions.map(&:code_insee))
          .includes(:users)
          .to_a
          .index_by(&:code_insee)

        (batch.count - revisions.count).times { @progressbar.increment }
        revisions.each do |revision|
          revision.commune = communes_by_code_insee[revision.code_insee]
          revision.synchronize if revision.commune
          @progressbar.increment
        end
      end

      def client
        @client ||= ApiClientAnnuaireAdministration.new
      end

      def iterate_revisions(&block)
        client.each { block.call(Revision.new(_1)) }
      end

      def code_insees_with_multiple_mairies
        @code_insees_with_multiple_mairies ||= compute_code_insees_with_multiple_mairies
      end

      def compute_code_insees_with_multiple_mairies
        counts = Hash.new(0)
        iterate_revisions do |revision|
          next if !revision.mairie? || revision.mairie_annexe?

          counts[revision.code_insee] += 1
        end
        counts.select { |_code, count| count > 1 }.map(&:first)
        Rails.logger.info "found #{codes.count} codes insees that match " \
                          "multiple mairies principales : #{codes[0..10]}..."
      end

      def revisions_for_code_insees_with_multiple_communes
        revisions_by_code_insee = Hash.new { |h, k| h[k] = [] } # code_insee => [revisions]
        iterate_revisions do |revision|
          next if !revision.mairie? || revision.mairie_annexe?
          next if code_insees_with_multiple_mairies.exclude?(revision.code_insee)

          revisions_by_code_insee[revision.code_insee] << revision
        end
        # revisions_by_code_insee.each do |code_insee, revisions|
        #   Rails.logger.info "code_insee #{code_insee}"
        #   revisions.each { Rails.logger.info _1 }
        # end
        []
      end
    end
  end
end

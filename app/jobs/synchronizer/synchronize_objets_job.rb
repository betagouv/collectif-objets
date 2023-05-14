# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsJob
    include Sidekiq::Job

    def initialize
      @counters = Hash.new(0)
    end

    # on_sensitive_change : :log | :apply_safe_changes | :interactive

    def perform(params = {})
      @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
      limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access[:dry_run]
      @on_sensitive_change = params.with_indifferent_access[:on_sensitive_change]&.to_sym || :log
      code_insee = params.with_indifferent_access[:code_insee]
      ApiClientSql.objets(logger:, limit:, code_insee:).iterate_batches { synchronize_rows(_1) }
      close
    end

    private

    attr_reader :on_sensitive_change

    def synchronize_rows(rows)
      batch = ObjetRevisionsBatch.from_rows(rows, on_sensitive_change:)
      batch.revisions_by_action.each do |action, revisions|
        @counters[action] += revisions.count
        revisions.each { synchronize_revision(_1) }
      end
    end

    def synchronize_revision(revision)
      @logfile.puts(revision.log_message) if revision.log_message.present?
      @logfile.flush
      revision.objet.save! if save_revision?(revision)
    end

    def close
      @logfile.puts "counters: #{@counters}"
      @logfile.close
    end

    def timestamp
      Time.zone.now.strftime("%Y_%m_%d_%HH%M")
    end

    def save_revision?(revision)
      return false if @dry_run

      return true if revision.save?

      return false unless interactive?

      return false unless revision.action.to_s.ends_with?("_invalid")

      chomp_save_revision?(revision)
    end

    # rubocop:disable Rails/Output
    def chomp_save_revision?(revision)
      puts "\n----\n#{revision.log_message}\n----"
      response = nil
      while response.nil?
        puts "voulez-vous forcer la sauvegarde de cet objet ? 'oui' : 'non'"
        raw = gets.chomp
        response = false if raw == "non"
        response = true if raw == "oui"
      end
      response
    end

    def interactive? = on_sensitive_change == :interactive
  end
  # rubocop:enable Rails/Output
end

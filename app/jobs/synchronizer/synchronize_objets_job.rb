# frozen_string_literal: true

module Synchronizer
  class SynchronizeObjetsJob
    include Sidekiq::Job

    # API_URL = "https://collectif-objets-datasette.fly.dev/data/palissy.json"
    API_URL = "http://localhost:8001/data/palissy.json"
    PER_PAGE = 1000
    BASE_PARAMS = {
      _size: PER_PAGE.to_s,
      _sort: "REF",
      _shape: "objects",
      _col: %w[REF DENO CATE COM INSEE DPT SCLE DENQ DOSS EDIF EMPL TICO],
      DOSS: "dossier individuel",
      PROT__not: "déclassé",
      STAT__arraynotcontains: ["propriété de l'Etat (?)", "propriété de l'Etat"],
      MANQUANT__not: %w[volé manquant],
      _json: ObjetRow::JSON_FIELDS
    }.freeze

    def initialize
      @counters = Hash.new(0)
    end

    def perform(params = {})
      @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
      @limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access["dry_run"]
      initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS)}"
      ApiClient.new(initial_url, logger:).iterate { |batch| synchronize_rows(batch) }
      close
    end

    private

    def synchronize_rows(rows)
      batch = ObjetRowsBatch.call_with(rows)
      Rails.logger.info "batch #{batch}"
      batch.rows_by_action.each do |action, subrows|
        @counters[action] += subrows.count
        subrows.each { synchronize_row(_1) }
      end
    end

    def synchronize_row(row)
      @logfile.puts(row.log_message) if row.log_message.present?
      return if @dry_run || !row.save?

      row.objet.save!
    end

    def close
      @logfile.puts "counters: #{@counters}"
      @logfile.close
    end

    def timestamp
      Time.zone.now.strftime("%Y_%m_%d_%HH%M")
    end
  end
end

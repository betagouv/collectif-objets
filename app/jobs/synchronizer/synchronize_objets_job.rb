# frozen_string_literal: true

class CustomValidationError < StandardError; end

module Synchronizer
  class SynchronizeObjetsJob
    include Sidekiq::Job
    include ApiMethods

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
      _json: ObjetBuilder::JSON_FIELDS
    }.freeze

    def initialize
      @counters = { new: 0, updated: 0, dropped_updates: 0 }
    end

    def perform(params = {})
      @logfile = File.open("tmp/synchronize-objets-#{timestamp}.log", "a+")
      @limit = params.with_indifferent_access[:limit]
      @dry_run = params.with_indifferent_access["dry_run"]
      initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS)}"
      iterate_api_requests(initial_url) { |batch| synchronize_rows(batch) }
    end

    private

    def synchronize_rows(rows)
      batch = ObjetRowsBatch.call_with(rows)
      Rails.logger.info "batch #{batch}"
      batch.new_objets.each { create_objet!(_1) }
      batch.objets_with_updates.each { update_objet!(_1) }
      batch.dropped_objets_with_updates.each { log_dropped_update(_1) }
      @counters[:dropped_updates] += batch.dropped_objets_with_updates.count
    end

    def create_objet!(objet)
      return if objet.palissy_TICO == "Traitement en cours"

      validate_objet!(objet)
      @counters[:new] += 1

      message = "objet #{objet['REF']} creation #{objet.attributes.except('REF').compact}"
      return logger.info message if @dry_run

      objet.save!
    end

    def update_objet!(objet)
      validate_objet!(objet)
      @counters[:updated] += 1

      message = "objet #{objet.palissy_REF} update with #{objet.changes}"
      return logger.info message if @dry_run

      objet.save!
    end

    def log_dropped_update(objet)
      @logfile.puts "dropped update for objet #{objet.palissy_REF} with #{objet.changes}"
    end

    def validate_objet!(objet)
      return if objet.valid?

      logger.warn "erreur pour l'objet #{objet.palissy_REF} - errors #{objet.changes}"
      raise CustomValidationError, objet.errors
    end

    def close
      logger.info "--- CLOSING --- #{@counters}"
      @logfile.puts "\n #{@counters}"
      @logfile.close
    end

    def timestamp
      Time.zone.now.strftime("%Y_%m_%d_%HH%M")
    end
  end
end

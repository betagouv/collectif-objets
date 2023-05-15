# frozen_string_literal: true

module Synchronizer
  class ObjetRevisionUpdate
    include ObjetRevisionConcern

    validate :validate_objet
    validate :validate_tico_en_cours

    def initialize(row, commune: nil, persisted_objet: nil, interactive: false, logfile: nil, dry_run: true)
      @row = row
      @commune = commune
      @persisted_objet = persisted_objet
      @interactive = interactive
      @logfile = logfile
      @dry_run = dry_run
      @commune_before_update = persisted_objet.commune
    end

    def objet
      @objet ||= ObjetBuilder.new(row, persisted_objet:).objet
    end

    def action
      return :not_changed unless changed?
      return :update_invalid unless valid?

      save_only_safe_updates? ? :update_safe : :update
    end

    def synchronize
      log log_message

      return false if dry_run? || !valid? || !changed?

      objet_to_save = save_all_updates? ? objet : objet_without_commune_change
      objet_to_save.save!
    end

    def log_message
      case action
      when :update
        "mise à jour de l’objet #{ref} avec #{objet.changes}"
      when :update_invalid
        "mise à jour interdite de l’objet #{ref} car #{errors_s}. changements annulés : #{objet.changes}"
      end
    end

    private

    attr_reader :persisted_objet, :commune_before_update

    def unsafe_commune_change_reason
      return "changement de commune vers commune en cours de recensement" if commune_after_update.started?

      if commune_after_update.completed? && commune_after_update.dossier.submitted?
        return "changement de commune vers commune avec dossier en cours d’analyse"
      end

      return "changement de commune depuis une commune en cours de recensement" if commune_before_update.started?

      return "changement de commune depuis une commune ayant fini de recenser" if commune_before_update.completed?

      nil
    end

    def objet_without_commune_change
      ObjetBuilder.new(row, persisted_objet:, without_commune_change: true).objet
    end

    def safe_commune_change? = unsafe_commune_change_reason.nil?
    def commune_changed? = commune_before_update != commune_after_update
    alias commune_after_update commune

    def save_all_updates? = !commune_changed? || safe_commune_change? || interactive_validation?
    def save_only_safe_updates? = !save_all_updates?
  end
end

# frozen_string_literal: true

module Synchronizer
  class ObjetRevisionUpdate
    include ObjetRevisionConcern

    def initialize(row, commune: nil, persisted_objet: nil, interactive: false, logfile: nil, dry_run: false)
      @row = row
      @commune = commune
      @persisted_objet = persisted_objet
      @interactive = interactive
      @logfile = logfile
      @dry_run = dry_run
      @commune_before_update = persisted_objet.commune
    end

    def synchronize
      return false unless check_changed

      persisted_objet.assign_attributes attributes_to_assign

      return false unless check_objet_valid

      set_update_action_and_log
      persisted_objet.save! unless dry_run?
      true
    end

    def objet = persisted_objet

    private

    attr_reader :persisted_objet, :commune_before_update
    alias commune_after_update commune

    def attributes_to_assign
      except_fields = ["REF"]
      except_fields += %w[COM INSEE DPT EDIF EMPL] if ignore_commune_change?
      objet_builder.attributes.except(*except_fields.map { "palissy_#{_1}" })
    end

    def check_changed
      return true if changed?

      @action = :not_changed
      false
    end

    def check_objet_valid
      return true if persisted_objet.valid?

      @action = :update_rejected_invalid
      log "mise à jour de l'objet #{palissy_ref} rejetée car l’objet n'est pas valide " \
          ": #{persisted_objet.errors.full_messages.to_sentence}"
      false
    end

    def objet_builder
      @objet_builder ||= ObjetBuilder.new(row, persisted_objet:)
    end

    def unsafe_commune_change_reason
      return "commune destinataire en cours de recensement" if commune_after_update.started?

      if commune_after_update.completed? && commune_after_update.dossier.submitted?
        return "commune destinataire avec dossier en cours d'examen"
      end

      return "commune d’origine en cours de recensement" if commune_before_update.started?

      return "commune d’origine ayant fini de recenser" if commune_before_update.completed?

      nil
    end

    def commune_changed? = commune_before_update != commune_after_update
    def safe_commune_change? = unsafe_commune_change_reason.nil?
    def apply_commune_change? = commune_changed? && (safe_commune_change? || interactive_validation?)
    def ignore_commune_change? = commune_changed? && !apply_commune_change?

    def set_update_action_and_log
      message = "mise à jour de l’objet #{palissy_ref}"
      if apply_commune_change?
        message += " avec changement de commune appliqué #{commune_before_update} → #{commune_after_update} "
        @action = :update_with_commune_change
      elsif ignore_commune_change?
        message += " avec changement de commune ignoré #{commune_before_update} → #{commune_after_update} " \
                   "(#{unsafe_commune_change_reason})"
        @action = :update_ignoring_commune_change
      else
        @action = :update
      end
      message += " : #{persisted_objet.changes}"
      log message
    end
  end
end

# frozen_string_literal: true

module Synchronizer
  class ObjetRevisionInsert
    include ObjetRevisionConcern

    validate :validate_objet
    validate :validate_tico_en_cours
    validate :validate_commune_inactive_or_accepted

    def initialize(row, commune:, interactive: false, logfile: nil, dry_run: false)
      @row = row
      @commune = commune
      @interactive = interactive
      @logfile = logfile
      @dry_run = dry_run
    end

    def objet
      @objet ||= ObjetBuilder.new(row).objet
    end

    def action
      return :not_changed unless changed?

      valid? ? :create : :create_invalid
    end

    def synchronize
      log log_message
      objet.save! if should_save?
    end

    def log_message
      case action
      when :create
        "création de l’objet #{ref} avec #{objet_attributes_s}"
      when :create_invalid
        "création interdite de l’objet #{ref} car #{errors_s}. attributs : #{objet_attributes_s}"
      end
    end

    private

    def should_save?
      !@dry_run && changed? && (valid? || interactive_validation?)
    end

    def validate_commune_inactive_or_accepted
      return true if commune.inactive? || commune.dossier&.accepted?

      @errors.add(:base, "la commune #{commune} est #{commune.status}")
    end
  end
end

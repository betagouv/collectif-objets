# frozen_string_literal: true

module Synchronizer
  class ObjetRevision
    delegate :changed?, to: :objet

    include ActiveModel::Validations
    validate :validate_objet
    validate :validate_commune_inactive
    validate :validate_initial_commune_inactive
    validate :validate_tico_en_cours

    attr_reader :objet

    def self.from_row(row, commune: nil, persisted_objet: nil)
      commune_before_update = persisted_objet&.commune
      objet = ObjetBuilder.new(row, persisted_objet:).objet
      commune ||= objet.commune
      new(objet:, commune:, commune_before_update:)
    end

    def initialize(objet:, commune: nil, commune_before_update: nil)
      @objet = objet
      @commune = commune || objet.commune || raise(ArgumentError, "missing commune for objet #{objet.palissy_REF}")
      @commune_before_update = commune_before_update
    end

    def action
      return :"#{action_simple}_invalid" if %i[create update].include?(action_simple) && !valid?

      action_simple
    end

    def log_message
      case action
      when :create
        "création de l’objet #{ref} avec #{objet_attributes_s}"
      when :update
        "mise à jour de l’objet #{ref} avec #{objet.changes}"
      when :create_invalid
        "création interdite de l’objet #{ref} car #{errors_s}. attributs : #{objet_attributes_s}"
      when :update_invalid
        "mise à jour interdite de l’objet #{ref} car #{errors_s}. changements annulés : #{objet.changes}"
      end
    end

    def save?
      %i[create update].include?(action)
    end

    private

    attr_reader :commune, :commune_before_update
    alias commune_after_update commune

    def validate_objet
      return true if objet.valid?

      @errors.add(:base, "l'objet n'est pas valide : ")
    end

    def validate_tico_en_cours
      return true if objet.palissy_TICO != "Traitement en cours"

      @errors.add(:base, "l'objet est en cours de traitement par POP")
    end

    def validate_commune_inactive
      return true if @commune.inactive? || commune.dossier&.accepted? || minor_changes?

      @errors.add(:base, "la commune #{@commune} est #{@commune.status}")
    end

    def validate_initial_commune_inactive
      return true if !commune_changed? || commune_before_update.inactive?

      @errors.add(
        :base,
        "la commune initiale (#{commune_before_update}) est #{commune_before_update.status}" \
        "(commune après MAJ : #{commune_after_update})"
      )
    end

    def action_simple
      return :create if objet.new_record?

      changed? ? :update : :not_changed
    end

    def minor_changes?
      objet.persisted? && (objet.changed - %w[palissy_DENQ palissy_COM palissy_REFA]).empty?
      # TODO: remove palissy_REFA
    end

    def ref = objet.palissy_REF

    def errors_s = errors.full_messages.to_sentence

    def objet_attributes_s
      objet.attributes.except("palissy_REF").compact
    end

    def commune_changed?
      commune_before_update.present? && commune_before_update != commune_after_update
    end
  end
end

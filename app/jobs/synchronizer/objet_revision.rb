# frozen_string_literal: true

module Synchronizer
  class ObjetRevision
    delegate :changed?, to: :objet

    include ActiveModel::Validations
    validate :validate_objet
    validate :validate_commune_safe
    validate :validate_commune_before_update_safe
    validate :validate_tico_en_cours

    attr_reader :objet

    def initialize(row, commune: nil, persisted_objet: nil, on_sensitive_change: :log)
      @commune = commune ||
                 Commune.find_by(code_insee: row["INSEE"]) ||
                 raise(ArgumentError, "missing commune for objet #{row['REF']}")
      @commune_before_update = persisted_objet&.commune
      safe_fields_only = !communes_safe? && on_sensitive_change == :apply_safe_changes
      @objet = ObjetBuilder.new(row, persisted_objet:, safe_fields_only:).objet
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

    def validate_commune_safe
      return true if commune_safe? || update_with_safe_changes?

      @errors.add(:base, "la commune #{commune} est #{commune.status}")
    end

    def validate_commune_before_update_safe
      return true if commune_before_update_safe?

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

    def ref = objet.palissy_REF
    def errors_s = errors.full_messages.to_sentence

    def objet_attributes_s = objet.attributes.except("palissy_REF").compact
    def update_with_safe_changes? = objet.persisted? && sensitive_changes.empty?
    def sensitive_changes = objet.changed - ObjetBuilder::SAFE_FIELDS.map { "palissy_#{_1}" }
    def commune_safe? = commune.inactive? || commune.dossier&.accepted?
    def commune_before_update_safe? = !commune_changed? || commune_before_update.inactive?
    def commune_changed? = commune_before_update.present? && commune_before_update != commune_after_update
    def communes_safe? = commune_safe? && commune_before_update_safe?
  end
end

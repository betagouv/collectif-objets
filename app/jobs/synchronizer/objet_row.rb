# frozen_string_literal: true

module Synchronizer
  class ObjetRow
    JSON_FIELDS = %w[DENO CATE SCLE DENQ].freeze
    TEXT_FIELDS = %w[COM INSEE DPT DOSS EDIF EMPL TICO].freeze
    ALL_FIELDS = (JSON_FIELDS + TEXT_FIELDS).freeze

    delegate :changed?, to: :objet

    include ActiveModel::Validations
    validate :validate_objet
    validate :validate_commune_inactive
    validate :validate_initial_commune_inactive
    validate :validate_tico_en_cours

    def initialize(row, commune:, persisted_objet: nil)
      @row = row
      @commune = commune
      @persisted_objet = persisted_objet
      @commune_before_update = persisted_objet&.commune
    end

    def objet
      @objet ||= \
        if @persisted_objet.present?
          @persisted_objet.assign_attributes(attributes.except("palissy_REF"))
          @persisted_objet
        else
          Objet.new(attributes)
        end
    end

    def action
      return :"#{action_simple}_invalid" if %i[create update].include?(action_simple) && !valid?

      action_simple
    end

    def log_message
      case action
      when :create
        "création de l'objet #{ref} avec #{objet_attributes_s}"
      when :update
        "mise à jour de l'objet #{ref} avec #{objet.changes}"
      when :create_invalid
        "X création interdite de l'objet #{ref} car #{errors_s}. attributs : #{objet_attributes_s}"
      when :update_invalid
        "mise à jour interdite de l'objet #{ref} car #{errors_s}. changements annulés : #{objet.changes}"
      end
    end

    def save?
      %i[create update].include?(action)
    end

    private

    attr_reader :commune, :commune_before_update
    alias commune_after_update commune

    def attributes
      @attributes ||= { "palissy_REF" => @row["REF"] } \
        .merge(json_fields)
        .merge(text_fields)
    end

    def validate_objet
      return true if objet.valid?

      @errors.add(:base, "l'objet n'est pas valide : ")
    end

    def validate_tico_en_cours
      return true if attributes["palissy_TICO"] != "Traitement en cours"

      @errors.add(:base, "l'objet est en cours de traitement par POP")
    end

    def validate_commune_inactive
      return true if @commune.inactive? || minor_changes?

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

    def json_fields
      JSON_FIELDS.to_h { ["palissy_#{_1}", @row[_1]&.any? ? @row[_1]&.join(";") : nil] }
    end

    def text_fields
      TEXT_FIELDS.to_h { ["palissy_#{_1}", @row[_1]] }
    end

    def action_simple
      return :create if objet.new_record?

      changed? ? :update : :not_changed
    end

    def minor_changes?
      objet.persisted? && (objet.changed - %w[palissy_DENQ palissy_COM]).empty?
    end

    def ref
      attributes["palissy_REF"]
    end

    def errors_s
      errors.full_messages.to_sentence
    end

    def objet_attributes_s
      objet.attributes.except("palissy_REF").compact
    end

    def commune_changed?
      commune_before_update.present? && commune_before_update != commune_after_update
    end
  end
end

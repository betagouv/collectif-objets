# frozen_string_literal: true

module Synchronizer
  class ObjetBuilder
    JSON_FIELDS = %w[DENO CATE SCLE DENQ].freeze
    TEXT_FIELDS = %w[COM INSEE DPT DOSS EDIF EMPL TICO].freeze
    ALL_FIELDS = (JSON_FIELDS + TEXT_FIELDS).freeze

    delegate :changed?, to: :objet_with_updates

    def initialize(row, persisted_objet: nil)
      @row = row
      @persisted_objet = persisted_objet
    end

    def attributes
      @attributes ||= { "palissy_REF" => @row["REF"] } \
        .merge(json_fields)
        .merge(text_fields)
    end

    def objet_with_updates
      raise if @persisted_objet.nil?

      @objet_with_updates ||= @persisted_objet.clone.tap { _1.assign_attributes(attributes.except("palissy_REF")) }
    end

    def can_update?
      @persisted_objet.present? &&
        @persisted_objet.persisted? && (
          @persisted_objet.commune.nil? ||
          @persisted_objet.commune.inactive? ||
          objet_with_updates.changed == ["palissy_DENQ"]
        )
    end

    private

    def json_fields
      JSON_FIELDS.to_h { ["palissy_#{_1}", @row[_1]&.any? ? @row[_1]&.join(";") : nil] }
    end

    def text_fields
      TEXT_FIELDS.to_h { ["palissy_#{_1}", @row[_1]] }
    end

    def persisted_objet_attributes
      @persisted_objet_attributes ||= @persisted_objet.attributes.slice(*attributes.keys)
    end
  end
end

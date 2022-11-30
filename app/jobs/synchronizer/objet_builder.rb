# frozen_string_literal: true

module Synchronizer
  class ObjetBuilder
    JSON_FIELDS = %w[DENO CATE SCLE DENQ].freeze
    TEXT_FIELDS = %w[COM INSEE DPT DOSS EDIF EMPL TICO].freeze
    ALL_FIELDS = (JSON_FIELDS + TEXT_FIELDS).freeze

    def initialize(row, persisted_objet: nil)
      @row = row
      @persisted_objet = persisted_objet
    end

    def objet
      if @persisted_objet.present?
        @persisted_objet.assign_attributes(attributes.except("palissy_REF"))
        @persisted_objet
      else
        Objet.new(attributes)
      end
    end

    private

    attr_reader :row

    def attributes
      @attributes ||= { "palissy_REF" => row["REF"] } \
        .merge(json_fields)
        .merge(text_fields)
        .merge({ "palissy_REFA" => ref_merimee })
    end

    def json_fields
      JSON_FIELDS.to_h do |field|
        arr = row[field] ? JSON.parse(row[field]) : []
        ["palissy_#{field}", arr&.any? ? arr&.join(";") : nil]
      end
    end

    def text_fields
      TEXT_FIELDS.to_h { ["palissy_#{_1}", row[_1]] }
    end

    def ref_merimee
      return nil if row["REFS_MERIMEE"].blank?

      possible_values = row["REFS_MERIMEE"].split(",").select { _1.starts_with?("PA") }
      return nil unless possible_values.count == 1

      possible_values[0]
    end
  end
end

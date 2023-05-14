# frozen_string_literal: true

module Synchronizer
  class ObjetBuilder
    JSON_FIELDS = %w[DENO CATE SCLE DENQ].freeze
    TEXT_FIELDS = %w[COM INSEE DPT DOSS EDIF EMPL TICO DPRO PROT].freeze
    ALL_FIELDS = (JSON_FIELDS + TEXT_FIELDS).freeze
    SAFE_FIELDS = %w[DENO CATE SCLE DENQ TICO DPRO PROT].freeze

    def initialize(row, persisted_objet: nil, safe_fields_only: false)
      @row = row
      @persisted_objet = persisted_objet
      @safe_fields_only = safe_fields_only
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

    attr_reader :row, :safe_fields_only

    def attributes
      @attributes ||= { "palissy_REF" => row["REF"] }
        .merge(json_values)
        .merge(text_values)
        .merge({ "palissy_REFA" => ref_merimee })
        .merge(edifice_id.present? ? { "edifice_id" => edifice_id } : {})
    end

    def json_values
      json_fields.to_h do |field|
        arr = row[field] ? JSON.parse(row[field]) : []
        ["palissy_#{field}", arr&.any? ? arr&.join(";") : nil]
      end
    end

    def text_values = text_fields.to_h { ["palissy_#{_1}", row[_1]] }

    def json_fields = safe_fields_only ? JSON_FIELDS & SAFE_FIELDS : JSON_FIELDS
    def text_fields = safe_fields_only ? TEXT_FIELDS & SAFE_FIELDS : TEXT_FIELDS

    def ref_merimee
      return nil if row["REFS_MERIMEE"].blank?

      possible_values = row["REFS_MERIMEE"].split(",").select { _1.starts_with?("PA") }
      return nil unless possible_values.count == 1

      possible_values[0]
    end

    def edifice_id
      return nil if @persisted_objet&.edifice_id&.present? || row["INSEE"].nil?

      merimee_edifice&.id || custom_edifice.id
    end

    def merimee_edifice
      return nil if ref_merimee.blank?

      edifice = Edifice.find_or_create_and_synchronize!(ref_merimee)

      return edifice if edifice.code_insee == row["INSEE"]
    end

    def custom_edifice
      atts = { code_insee: row["INSEE"], slug: Edifice.slug_for(row["EDIF"]), nom: row["EDIF"] }
      Edifice.where(atts.slice(:code_insee, :slug)).first_or_create!(atts)
    end
  end
end

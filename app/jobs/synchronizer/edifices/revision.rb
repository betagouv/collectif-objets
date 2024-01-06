# frozen_string_literal: true

module Synchronizer
  module Edifices
    class Revision
      def initialize(row)
        @row = row
      end

      def synchronize
        puts "attributes is #{@attributes}"
        return unless edifice

        edifice.assign_attributes(attributes)
        return unless edifice.changed?

        if edifice.code_insee_was.present? && edifice.code_insee.nil?
          Rails.logger.info "ERROR ! edifice #{@identified_by} would lose its code_insee (#{edifice.code_insee_was})"
          return
        end

        Rails.logger.info "edifice #{@identified_by} changed : #{edifice.changes}, saving..."
        edifice.save
        return unless edifice.errors.any?

        Rails.logger.info "ERROR ! edifice #{@identified_by} errors : #{edifice.errors}"
        raise edifice.errors.full_messages.join(", ")
      end

      private

      def edifice
        @edifice ||= find_edifice
      end

      def find_edifice
        @identified_by = attributes.slice(:merimee_REF)
        edifice = Edifice.find_by(@identified_by)
        return edifice if edifice

        @identified_by = attributes.slice(:code_insee, :slug)
        return if @identified_by.values.any?(&:blank?)

        Edifice.find_by(**@identified_by, merimee_REF: nil)
      end

      def attributes
        # code_insee is a single string value using the CSV but an array using the API 🤷‍♂️
        code_insee = @row["cog_insee"]
        code_insee = code_insee[0] if code_insee.is_a?(Array)
        {
          merimee_REF: @row["reference"],
          nom: @row["titre_editorial_de_la_notice"],
          # merimee_PRODUCTEUR: @row["PRODUCTEUR"],
          code_insee:,
          slug: Edifice.slug_for(@row["titre_editorial_de_la_notice"])
        }
      end
    end
  end
end

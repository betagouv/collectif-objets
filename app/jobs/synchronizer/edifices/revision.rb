# frozen_string_literal: true

module Synchronizer
  module Edifices
    class Revision
      include LogConcern

      def initialize(edifice_attributes, logger: nil)
        @edifice_attributes = edifice_attributes
        @logger = logger
      end

      def synchronize
        @edifice = existing_edifice

        return if !row_valid? || !@edifice

        merge_existing_edifices if two_existing_edifices?

        @edifice.assign_attributes(edifice_attributes)

        return log(nil, counter: :unchanged) unless @edifice.changed?

        return log_update_error unless @edifice.valid?

        log "#{@edifice} changed : #{@edifice.changes}", counter: :update
        @edifice.save!
      end

      private

      attr_reader :edifice_attributes

      def row_valid?
        # maybe we should just skip
        raise "missing merimee_REF in #{edifice_attributes}" if edifice_attributes[:merimee_REF].blank?

        edifice_attributes[:code_insee].present?
      end

      def existing_edifice_by_ref
        @existing_edifice_by_ref ||= Edifice.find_by(edifice_attributes.slice(:merimee_REF))
      end

      def existing_edifice_by_slug
        return nil if edifice_attributes[:slug].blank? || edifice_attributes[:code_insee].blank?

        @existing_edifice_by_slug ||= Edifice.find_by(**edifice_attributes.slice(:slug, :code_insee), merimee_REF: nil)
      end

      def existing_edifice
        @existing_edifice ||= existing_edifice_by_ref || existing_edifice_by_slug
      end

      def two_existing_edifices? = existing_edifice_by_ref && existing_edifice_by_slug

      def log_update_error
        log "error when saving #{@edifice.changes} : #{@edifice.errors.full_messages}", counter: :update_error
      end

      def merge_existing_edifices
        log "merging #{existing_edifice_by_slug} into #{existing_edifice_by_ref}", counter: :edifices_merged
        Objet
          .where(edifice: existing_edifice_by_slug)
          .update_all(edifice_id: existing_edifice_by_ref.id)
        existing_edifice_by_slug.destroy!
        # at this point in time the objet may be associated to an edifice with a different code INSEE
        # but it will be fixed in the edifice.save! call
      end
    end
  end
end

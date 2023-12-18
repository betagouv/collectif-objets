# frozen_string_literal: true

module Co
  module Communes
    class ObjetsList
      delegate :any?, to: :objets

      attr_reader :edifice, :commune

      def initialize(commune, scoped_objets: Objet.all, exclude_recensed: false, exclude_ids: [], edifice: nil)
        @commune = commune
        @exclude_ids = exclude_ids
        @exclude_recensed = exclude_recensed
        @edifice = edifice
        @scoped_objets = scoped_objets
      end

      def edifices
        @edifices ||= commune
          .edifices
          .with_objets
          .includes(objets: { recensements: %i[photos_attachments photos_blobs] })
          .ordered_by_nom
      end

      def objets
        @objets ||= begin
          objets = scoped_objets
            .where(commune: @commune)
            .includes(:commune, recensements: %i[photos_attachments photos_blobs])
          objets = objets.without_completed_recensements if @exclude_recensed
          objets = objets.where.not(id: @exclude_ids) if @exclude_ids.any?
          objets = objets.where(edifice: @edifice) if @edifice.present?
          objets
        end
      end

      def edifices_count
        @edifices_count ||= edifices.count
      end

      delegate :count, to: :objets

      protected

      attr_reader :scoped_objets

      def recensement_saved?
        false
      end
    end
  end
end

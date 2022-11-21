# frozen_string_literal: true

module Co
  module Communes
    class ObjetsList
      delegate :any?, to: :objets

      attr_reader :edifice_nom

      def initialize(commune, scoped_objets: Objet.all, exclude_recensed: false, exclude_ids: [], edifice_nom: nil)
        @commune = commune
        @exclude_ids = exclude_ids
        @exclude_recensed = exclude_recensed
        @edifice_nom = edifice_nom
        @scoped_objets = scoped_objets
      end

      def group_by_edifice?
        @group_by_edifice ||= @commune.objets.count > 10 && edifices_count > 2
      end

      def edifices
        @edifices ||= objets
          .group_by(&:palissy_EDIF)
          .sort_by { |k, _v| k.presence&.parameterize || "zzz" }
          .map { edifice_group_hash(*_1) }
      end

      def objets
        @objets ||= begin
          objets = scoped_objets
            .where(commune: @commune)
            .with_photos_first
            .includes(:commune, recensements: %i[photos_attachments photos_blobs])
          objets = objets.where.missing(:recensements) if @exclude_recensed
          objets = objets.where.not(id: @exclude_ids) if @exclude_ids.any?
          objets = objets.where(palissy_EDIF: @edifice_nom) if group_by_edifice? && @edifice_nom.present?
          objets
        end
      end

      def edifices_count
        @edifices_count ||= @commune.objets.group(:palissy_EDIF).count.keys.count
      end

      delegate :count, to: :objets

      protected

      attr_reader :scoped_objets

      def edifice_group_hash(nom_edifice, objets)
        {
          nom: nom_edifice,
          nom_parameterized: nom_edifice.presence&.parameterize || "edifice-na",
          objets:
        }
      end

      def recensement_saved?
        false
      end
    end
  end
end

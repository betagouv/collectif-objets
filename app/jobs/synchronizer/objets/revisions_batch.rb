# frozen_string_literal: true

module Synchronizer
  module Objets
    class RevisionsBatch
      def initialize(rows, revision_kwargs:)
        @rows = rows
        @revision_kwargs = revision_kwargs
      end

      def revisions
        rows.map { build_revision(_1) }.compact
      end

      private

      attr_reader :rows, :revision_kwargs

      def build_revision(row)
        persisted_objet = persisted_objets[row["REF"]]
        commune = all_communes[row["INSEE"]]
        return nil if commune.nil?

        if persisted_objet
          RevisionUpdate.new(row, persisted_objet:, commune:, **revision_kwargs)
        else
          RevisionInsert.new(row, commune:, **revision_kwargs)
        end
      end

      def to_s
        revisions_by_action.map { |label, revisions| "#{revisions.count} #{label} objets" }
      end

      def persisted_objets
        @persisted_objets ||= Objet
          .where(palissy_REF: @rows.pluck("REF"))
          .includes(:commune, :recensements)
          .to_a
          .index_by(&:palissy_REF)
      end

      def all_communes
        @all_communes ||= Commune
          .where(code_insee: @rows.pluck("INSEE"))
          .to_a
          .index_by(&:code_insee)
      end
    end
  end
end

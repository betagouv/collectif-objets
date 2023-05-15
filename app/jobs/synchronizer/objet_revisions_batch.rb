# frozen_string_literal: true

module Synchronizer
  class ObjetRevisionsBatch
    attr_reader :revisions_by_action

    def initialize(rows, revision_kwargs:)
      @rows = rows
      @revisions_by_action = {}
      @revision_kwargs = revision_kwargs
    end

    def prepare
      @rows.each { prepare_row(_1) }
    end

    def self.from_rows(rows, revision_kwargs:)
      o = new(rows, revision_kwargs:)
      o.prepare
      o
    end

    private

    attr_reader :revision_kwargs

    def prepare_row(row)
      revision = build_revision(row)
      return if revision.nil?

      @revisions_by_action[revision.action] ||= []
      @revisions_by_action[revision.action] << revision
    end

    def build_revision(row)
      persisted_objet = persisted_objets[row["REF"]]
      commune = all_communes[row["INSEE"]]
      return nil if commune.nil?

      if persisted_objet
        ObjetRevisionUpdate.new(row, persisted_objet:, commune:, **revision_kwargs)
      else
        ObjetRevisionInsert.new(row, commune:, **revision_kwargs)
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

# frozen_string_literal: true

class MissingCommuneError < StandardError; end

module Synchronizer
  class ObjetRevisionsBatch
    attr_reader :revisions_by_action

    def initialize(rows)
      @rows = rows
      @revisions_by_action = {}
    end

    def prepare
      @rows.each { prepare_row(_1) }
    end

    def self.from_rows(rows)
      o = new(rows)
      o.prepare
      o
    end

    private

    def prepare_row(row)
      revision = build_revision(row)
      return if revision.nil?

      @revisions_by_action[revision.action] ||= []
      @revisions_by_action[revision.action] << revision
    end

    def build_revision(row)
      persisted_objet = persisted_objets[row["REF"]]
      # commune = all_communes[row["INSEE"]] || raise(MissingCommuneError, row)
      commune = all_communes[row["INSEE"]]
      return nil if commune.nil?

      ObjetRevision.from_row(row, persisted_objet:, commune:)
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

# frozen_string_literal: true

class MissingCommuneError < StandardError; end

module Synchronizer
  class ObjetRevisionsBatch
    attr_reader :revisions_by_action

    def initialize(rows, on_sensitive_change:)
      @rows = rows
      @revisions_by_action = {}
      @on_sensitive_change = on_sensitive_change
    end

    def prepare
      @rows.each { prepare_row(_1) }
    end

    def self.from_rows(rows, on_sensitive_change:)
      o = new(rows, on_sensitive_change:)
      o.prepare
      o
    end

    private

    attr_reader :on_sensitive_change

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

      ObjetRevision.new(row, persisted_objet:, commune:, on_sensitive_change:)
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

# frozen_string_literal: true

class MissingCommuneError < StandardError; end

module Synchronizer
  class ObjetRowsBatch
    attr_reader :rows_by_action

    def initialize(raw_rows)
      @raw_rows = raw_rows
      @rows_by_action = Hash.new([])
    end

    def prepare
      @raw_rows.each { prepare_row(_1) }
    end

    def self.call_with(raw_rows)
      o = new(raw_rows)
      o.prepare
      o
    end

    private

    def prepare_row(raw_row)
      row = build_objet_row(raw_row)
      @rows_by_action[row.action] << row
    end

    def build_objet_row(raw_row)
      persisted_objet = persisted_objets[raw_row["REF"]]
      commune = all_communes[raw_row["INSEE"]] || raise(MissingCommuneError, raw_row.slice("INSEE", "COM").join(" - "))
      ObjetRow.new(raw_row, persisted_objet:, commune:)
    end

    def to_s
      rows_by_action.map { |label, rows| "#{rows.count} #{label} objets" }
    end

    def persisted_objets
      @persisted_objets ||= Objet
        .where(palissy_REF: @raw_rows.pluck("REF"))
        .includes(:commune, :recensements)
        .to_a
        .index_by(&:palissy_REF)
    end

    def all_communes
      @all_communes ||= Commune.where(code_insee: @raw_rows.pluck("INSEE"))
    end
  end
end

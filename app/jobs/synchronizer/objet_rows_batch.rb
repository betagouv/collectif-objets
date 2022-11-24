# frozen_string_literal: true

module Synchronizer
  class ObjetRowsBatch
    attr_reader :new_objets, :objets_with_updates, :dropped_objets_with_updates

    def initialize(rows)
      @rows = rows
      @new_objets = []
      @objets_with_updates = []
      @dropped_objets_with_updates = []
    end

    def synchronize
      @rows.each { synchronize_row(_1) }
    end

    def self.call_with(rows)
      o = new(rows)
      o.synchronize
      o
    end

    private

    def synchronize_row(row)
      persisted_objet = persisted_objets[row["REF"]]
      builder = ObjetBuilder.new(row, persisted_objet:)
      if persisted_objet.present? && builder.changed?
        target_bucket = builder.can_update? ? @objets_with_updates : @dropped_objets_with_updates
        target_bucket << builder.objet_with_updates
      elsif persisted_objet.nil?
        @new_objets << Objet.new(builder.attributes)
      end
    end

    def to_s
      "#{@new_objets.count} new objets - " \
        "#{@objets_with_updates.count} objets updates - " \
        "#{@dropped_objets_with_updates.count} dropped objets updates"
    end

    def persisted_objets
      @persisted_objets ||= Objet
        .where(palissy_REF: @rows.pluck("REF"))
        .includes(:commune, :recensements)
        .to_a
        .index_by(&:palissy_REF)
    end
  end
end

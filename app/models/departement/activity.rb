# frozen_string_literal: true

module Departement::Activity # rubocop:disable Style/ClassAndModuleChildren
  extend ActiveSupport::Concern

  class_methods do
    def with_activity_in(date_range)
      joins(:conservateurs).preload(:conservateurs)
        .left_joins(communes: [:messages, :dossier])
        .merge(Conservateur.send_recap)
        .merge(Message.from_commune.received_in(date_range))
        .or(merge(Dossier.submitted_in(date_range)))
        .distinct
        .select("departements.code, conservateurs.id")
        .to_h { |departement| [departement.code, departement.conservateurs.ids] }
    end
  end

  included do
    def commune_messages_count(date_range)
      communes.sort_by_nom.joins(:messages).merge(Message.from_commune.received_in(date_range)).tally
    end

    def commune_dossiers_transmis(date_range)
      communes.sort_by_nom.include_en_peril_and_disparus_count
              .joins(:dossier).where(dossiers: { submitted_at: date_range })
    end
  end
end

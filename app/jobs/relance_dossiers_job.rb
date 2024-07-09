# frozen_string_literal: true

class RelanceDossiersJob < ApplicationJob
  MOIS_RELANCE = 9
  MOIS_DERNIERE_RELANCE = 11

  class << self
    def dossiers
      Dossier.construction
    end

    def dossiers_a_relancer
      created_at = MOIS_RELANCE.months.ago.all_month
      dossiers.where(created_at:).ids
    end

    def dossiers_pour_derniere_relance
      created_at = MOIS_DERNIERE_RELANCE.months.ago.all_month
      dossiers.where(created_at:).ids
    end
  end

  delegate :dossiers_a_relancer, :dossiers_pour_derniere_relance, to: :class

  def perform
    dossiers_a_relancer.each { |id| RelanceDossierIncompletJob.perform_later(id) }
    dossiers_pour_derniere_relance.each { |id| DerniereRelanceDossierIncompletJob.perform_later(id) }
  end
end

# frozen_string_literal: true

class RelanceDossiersJob < ApplicationJob
  MOIS_RELANCE = 9
  MOIS_DERNIERE_RELANCE = 11
  MOIS_ARCHIVE = 12

  class << self
    def dossiers_created_in(created_at)
      Dossier.construction.where(created_at:).ids
    end

    def dossiers_a_relancer
      dossiers_created_in MOIS_RELANCE.months.ago.all_month
    end

    def dossiers_pour_derniere_relance
      dossiers_created_in MOIS_DERNIERE_RELANCE.months.ago.all_month
    end

    def dossiers_a_archiver
      dossiers_created_in (MOIS_ARCHIVE.months.ago..)
    end
  end

  delegate :dossiers_a_relancer, :dossiers_pour_derniere_relance, :dossiers_a_archiver, to: :class

  def perform
    dossiers_a_relancer.each { |id| RelanceDossierIncompletJob.perform_later(id) }
    dossiers_pour_derniere_relance.each { |id| DerniereRelanceDossierIncompletJob.perform_later(id) }
    dossiers_a_archiver.each { |id| ArchiveDossierIncompletJob.perform_later(id) }
  end
end

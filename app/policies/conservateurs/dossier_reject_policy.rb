# frozen_string_literal: true

module Conservateurs
  class DossierRejectPolicy < BasePolicy
    alias dossier_reject record

    delegate :dossier, to: :dossier_reject

    def create?
      conservateur.departements.include?(dossier.departement) &&
        dossier.submitted? &&
        dossier.commune.completed?
    end
    alias update? create?
  end
end

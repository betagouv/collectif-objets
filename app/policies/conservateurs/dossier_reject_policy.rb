# frozen_string_literal: true

module Conservateurs
  class DossierRejectPolicy < BasePolicy
    alias dossier_reject record

    delegate :dossier, to: :dossier_reject

    def new?
      conservateur.departements.include?(dossier.departement) &&
        dossier.submitted? &&
        dossier.commune.completed?
    end

    def create?
      new? && !impersonating?
    end
    alias update? create?
  end
end

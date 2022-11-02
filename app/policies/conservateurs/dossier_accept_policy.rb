# frozen_string_literal: true

module Conservateurs
  class DossierAcceptPolicy < BasePolicy
    alias dossier_accept record

    delegate :dossier, to: :dossier_accept

    def create?
      conservateur.departements.include?(dossier.departement) &&
        (dossier_commune_authorized? || dossier_conservateur_authorized?)
    end
    alias update? create?

    private

    def dossier_commune_authorized?
      dossier.author_user? &&
        dossier.submitted? &&
        dossier.commune.completed? &&
        dossier.recensements.not_analysed.empty?
    end

    def dossier_conservateur_authorized?
      dossier.author_conservateur? &&
        dossier.edifice.completed?
    end
  end
end

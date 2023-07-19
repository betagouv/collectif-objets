# frozen_string_literal: true

module Conservateurs
  class DossierAcceptPolicy < BasePolicy
    alias dossier_accept record

    delegate :dossier, to: :dossier_accept

    def new?
      can_change_dossier_state? && dossier.submitted?
    end

    def create?
      new? && !impersonating?
    end
    alias update? create?

    # Pour ré ouvrir un dossier
    def destroy?
      can_change_dossier_state? && dossier.accepted? && !impersonating?
    end

    private

    def can_change_dossier_state?
      conservateur.departements.include?(dossier.departement) &&
        dossier.commune.completed? &&
        dossier.recensements.not_analysed.empty?
    end
  end
end

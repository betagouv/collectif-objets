# frozen_string_literal: true

module Conservateurs
  class DossierAcceptPolicy < BasePolicy
    alias dossier_accept record

    delegate :dossier, to: :dossier_accept

    def new?
      conservateur.departements.include?(dossier.departement) &&
        dossier.submitted? &&
        dossier.commune.completed? &&
        dossier.recensements.not_analysed.empty?
    end

    def create?
      new? && !impersonating?
    end
    alias update? create?
  end
end

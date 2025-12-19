# frozen_string_literal: true

module Recenseurs
  class DossierCompletionPolicy < BasePolicy
    alias dossier_completion record
    delegate :commune, to: :dossier_completion

    def show?
      recenseur_has_full_access? && commune.completed?
    end

    def new?
      recenseur_has_full_access? && commune.started?
    end

    def create?
      new? && !impersonating?
    end

    private

    def recenseur_has_full_access?
      recenseur.granted_accesses.where(commune:, all_edifices: true).exists?
    end
  end
end

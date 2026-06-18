# frozen_string_literal: true

module Recenseurs
  class DossierPolicy < BasePolicy
    alias dossier record

    def show?
      recenseur_has_full_access_to_commune?
    end

    private

    def recenseur_has_full_access_to_commune?
      recenseur.granted_accesses.where(commune: dossier.commune, all_edifices: true).exists?
    end
  end
end

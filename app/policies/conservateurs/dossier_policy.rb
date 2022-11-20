# frozen_string_literal: true

module Conservateurs
  class DossierPolicy < BasePolicy
    alias dossier record

    def show?
      conservateur.departements.include?(dossier.departement) && dossier.accepted?
    end
  end
end

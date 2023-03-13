# frozen_string_literal: true

module Conservateurs
  class DossierPolicy < BasePolicy
    alias dossier record

    def show?
      conservateur.departements.include?(dossier.departement)
    end
  end
end

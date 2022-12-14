# frozen_string_literal: true

module Conservateurs
  class AnalysePolicy < BasePolicy
    alias analyse record

    def update?
      !impersonating? &&
        conservateur.departements.include?(analyse.departement) &&
        analyse.commune.completed? &&
        analyse.dossier.submitted?
    end
  end
end

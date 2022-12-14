# frozen_string_literal: true

module Conservateurs
  class AnalysePolicy < BasePolicy
    alias analyse record

    def edit?
      conservateur.departements.include?(analyse.departement) &&
        analyse.commune.completed? &&
        analyse.dossier.submitted?
    end

    def update?
      edit? && !impersonating?
    end
  end
end

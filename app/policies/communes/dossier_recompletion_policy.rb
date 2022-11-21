# frozen_string_literal: true

module Communes
  class DossierRecompletionPolicy < ApplicationPolicy
    alias dossier_recompletion record

    def create?
      user_commune? && dossier_recompletion.dossier.rejected?
    end

    private

    def user_commune?
      user.commune == dossier_recompletion.commune
    end
  end
end

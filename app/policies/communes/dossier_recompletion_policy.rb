# frozen_string_literal: true

module Communes
  class DossierRecompletionPolicy < BasePolicy
    alias dossier_recompletion record

    def new?
      user_commune? && dossier_recompletion.dossier.rejected?
    end

    def create?
      new? && !impersonating?
    end

    private

    def user_commune?
      user.commune == dossier_recompletion.commune
    end
  end
end

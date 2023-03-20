# frozen_string_literal: true

module Communes
  class DossierPolicy < BasePolicy
    alias dossier record

    def show?
      user_commune?
    end

    private

    def user_commune?
      user.commune == dossier.commune
    end
  end
end

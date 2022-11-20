# frozen_string_literal: true

module Communes
  class RecompletionPolicy < ApplicationPolicy
    alias recompletion record

    def create?
      user_commune? && recompletion.dossier.rejected?
    end

    private

    def user_commune?
      user.commune == recompletion.commune
    end
  end
end

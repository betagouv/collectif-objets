# frozen_string_literal: true

module Communes
  class DossierCompletionPolicy < ApplicationPolicy
    alias dossier_completion record
    delegate :commune, to: :dossier_completion

    def show?
      user_commune? && commune.completed?
    end

    def create?
      user_commune? && commune.started?
    end

    private

    def user_commune?
      user.commune == commune
    end
  end
end

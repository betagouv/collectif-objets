# frozen_string_literal: true

module Communes
  class DossierCompletionPolicy < BasePolicy
    alias dossier_completion record
    delegate :commune, to: :dossier_completion

    def show?
      user_commune? && commune.completed?
    end

    def new?
      user_commune? && commune.started?
    end

    def create?
      new? && !impersonating?
    end

    private

    def user_commune?
      user.commune == commune
    end
  end
end

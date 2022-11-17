# frozen_string_literal: true

module Communes
  class RecensementPolicy < ApplicationPolicy
    def create?
      user_commune? &&
        objet.current_recensement.nil? &&
        commune_can_edit?
    end

    def update?
      user_commune? &&
        commune_can_edit?
    end

    private

    delegate :objet, :commune, to: :record

    def user_commune?
      user.commune == commune
    end

    def commune_can_edit?
      !commune.completed? || commune.dossier&.rejected?
    end
  end
end

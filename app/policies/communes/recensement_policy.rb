# frozen_string_literal: true

module Communes
  class RecensementPolicy < BasePolicy
    def new?
      user_commune? &&
        (objet.recensement.nil? || objet.recensement.new_record?) &&
        commune_can_edit?
    end

    def create?
      new? && !impersonating?
    end

    def edit?
      user_commune? &&
        commune_can_edit?
    end

    def update?
      edit? && !impersonating?
    end

    def destroy?
      update?
    end

    private

    delegate :objet, :commune, to: :record

    def user_commune?
      user.commune == commune
    end

    def commune_can_edit?
      !commune.dossier&.accepted?
    end
  end
end

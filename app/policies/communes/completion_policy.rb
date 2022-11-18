# frozen_string_literal: true

module Communes
  class CompletionPolicy < ApplicationPolicy
    alias completion record
    delegate :commune, to: :completion

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

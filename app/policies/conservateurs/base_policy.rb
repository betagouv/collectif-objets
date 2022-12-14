# frozen_string_literal: true

module Conservateurs
  class BasePolicy < ApplicationPolicy
    alias conservateur user

    def impersonating?
      conservateur.impersonating
    end

    class Scope < Scope
      alias conservateur user
    end
  end
end

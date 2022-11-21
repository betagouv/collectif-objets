# frozen_string_literal: true

module Conservateurs
  class BasePolicy < ApplicationPolicy
    alias conservateur user

    class Scope < Scope
      alias conservateur user
    end
  end
end

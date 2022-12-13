# frozen_string_literal: true

module Communes
  class BasePolicy < ApplicationPolicy
    protected

    def impersonating?
      user.impersonating
    end
  end
end

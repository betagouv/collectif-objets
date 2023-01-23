# frozen_string_literal: true

module Communes
  class UserPolicy < BasePolicy
    def update?
      user == record
    end
  end
end

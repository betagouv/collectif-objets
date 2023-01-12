# frozen_string_literal: true

module Conservateurs
  class ConservateurPolicy < BasePolicy
    def update?
      conservateur == record
    end
  end
end

# frozen_string_literal: true

module Communes
  class RecenseurPolicy < BasePolicy
    def show?
      record.communes.include? user.commune
    end

    class Scope < Scope
      def resolve
        scope.joins(:communes).where(communes: user.commune)
      end
    end
  end
end

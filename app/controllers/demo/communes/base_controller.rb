# frozen_string_literal: true

module Demo
  module Communes
    class BaseController < Demo::BaseController
      def current_user
        commune = build(:commune)
        build(:user, commune:)
      end

      def policy(*, **)
        Struct.new(:new?).new(true)
      end
      helper_method :policy
    end
  end
end

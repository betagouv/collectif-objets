# frozen_string_literal: true

module Galerie
  module Actions
    module BaseConcern
      extend ActiveSupport::Concern

      included do
        attr_reader :responsive_variant
      end

      def button_component
        # all actions should have a button
        raise NotImplementedError
      end

      def confirmation_component
        # not all actions have a confirmation modal
      end
    end
  end
end

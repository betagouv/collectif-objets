# frozen_string_literal: true

module Galerie
  module Actions
    module ButtonConcern
      extend ActiveSupport::Concern

      included do
        attr_reader :responsive_variant
      end

      def button_icon_class
        classes = %w[action fr-btn]
        classes +=
          if responsive_variant == :desktop
            %w[fr-btn--sm fr-btn--icon-right fr-btn--secondary]
          elsif responsive_variant == :mobile
            %w[fr-btn--lg fr-btn--icon fr-btn--tertiary-no-outline]
          end
        classes.join(" ")
      end
    end
  end
end

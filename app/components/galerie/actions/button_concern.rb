# frozen_string_literal: true

module Galerie
  module Actions
    module ButtonConcern
      extend ActiveSupport::Concern

      included do
        attr_reader :with_text
      end

      def button_icon_class
        classes = %w[action fr-btn]
        classes +=
          if with_text
            %w[fr-btn--sm fr-btn--icon-right fr-btn--secondary]
          else
            %w[fr-btn--lg fr-btn--icon fr-btn--tertiary-no-outline]
          end
        classes.join(" ")
      end
    end
  end
end

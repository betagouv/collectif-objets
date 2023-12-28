# frozen_string_literal: true

module Galerie
  module Actions
    class Upload
      class ButtonComponent < ViewComponent::Base
        include ButtonConcern

        def initialize(responsive_variant: :desktop)
          super
          @responsive_variant = responsive_variant
        end
      end
    end
  end
end

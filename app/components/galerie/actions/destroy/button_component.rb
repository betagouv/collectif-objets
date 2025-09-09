# frozen_string_literal: true

module Galerie
  module Actions
    class Destroy
      class ButtonComponent < ApplicationComponent
        include ButtonConcern

        def initialize(responsive_variant: :desktop)
          super
          @responsive_variant = responsive_variant
        end
      end
    end
  end
end

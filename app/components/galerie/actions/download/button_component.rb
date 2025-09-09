# frozen_string_literal: true

module Galerie
  module Actions
    class Download
      class ButtonComponent < ApplicationComponent
        include ButtonConcern

        attr_reader :url

        def initialize(url:, responsive_variant: :desktop)
          super
          @responsive_variant = responsive_variant
          @url = url
        end
      end
    end
  end
end

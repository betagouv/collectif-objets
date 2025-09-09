# frozen_string_literal: true

module Galerie
  module Actions
    class Rotate
      class ButtonComponent < ApplicationComponent
        include ButtonConcern

        attr_reader :attachment_path, :redirect_path

        def initialize(attachment_path:, redirect_path:, responsive_variant: :desktop)
          super
          @responsive_variant = responsive_variant
          @attachment_path = attachment_path
          @redirect_path = redirect_path
        end
      end
    end
  end
end

# frozen_string_literal: true

module Galerie
  module Actions
    class Rotate
      include BaseConcern
      attr_reader :attachment_path, :redirect_path

      def initialize(attachment_path:, redirect_path:, responsive_variant: :desktop)
        @responsive_variant = responsive_variant
        @attachment_path = attachment_path
        @redirect_path = redirect_path
      end

      def button_component
        ButtonComponent.new(attachment_path:, redirect_path:, responsive_variant:)
      end
    end
  end
end

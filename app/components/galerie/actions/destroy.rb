# frozen_string_literal: true

module Galerie
  module Actions
    class Destroy
      include BaseConcern

      attr_reader :url, :attachment_path, :redirect_path

      def initialize(attachment_path:, redirect_path:, responsive_variant: :desktop)
        @responsive_variant = responsive_variant
        @attachment_path = attachment_path
        @redirect_path = redirect_path
      end

      def button_component
        ButtonComponent.new(responsive_variant:)
      end

      def confirmation_component
        ConfirmationComponent.new(attachment_path:, redirect_path:)
      end
    end
  end
end

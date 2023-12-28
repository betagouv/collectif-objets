# frozen_string_literal: true

module Galerie
  module Actions
    class Upload
      include BaseConcern

      attr_reader :attachments_path, :recensement_id, :redirect_path, :message

      def initialize(attachments_path:, recensement_id:, redirect_path:, message:, responsive_variant: :desktop)
        @responsive_variant = responsive_variant
        @attachments_path = attachments_path
        @recensement_id = recensement_id
        @redirect_path = redirect_path
        @message = message
      end

      def button_component
        ButtonComponent.new(responsive_variant:)
      end

      def confirmation_component
        ConfirmationComponent.new(attachments_path:, recensement_id:, redirect_path:, message:)
      end
    end
  end
end

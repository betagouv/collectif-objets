# frozen_string_literal: true

module Galerie
  module ActionGroups
    class ConservateurRecensement < Base
      delegate :close_path, :next_photo, to: :@galerie

      def initialize(galerie:, recensement:)
        super(galerie:)
        @recensement = recensement
      end

      def buttons(responsive_variant: :desktop)
        [
          download_button(responsive_variant:),
          rotate_button(responsive_variant:),
          destroy_button(responsive_variant:),
          upload_button(responsive_variant:)
        ].compact
      end

      def confirmations
        [destroy_confirmation, upload_confirmation].compact
      end

      def rotate_button(responsive_variant: :desktop)
        return nil if current_photo.nil?

        Galerie::Actions::Rotate::ButtonComponent.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: current_photo.lightbox_path,
          responsive_variant:
        )
      end

      def destroy_button(responsive_variant: :desktop)
        return nil if current_photo.nil?

        Galerie::Actions::Destroy::ButtonComponent.new(responsive_variant:)
      end

      def destroy_confirmation
        return nil if current_photo.nil?

        Galerie::Actions::Destroy::ConfirmationComponent.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: next_photo&.lightbox_path || previous_photo&.lightbox_path || close_path
        )
      end

      def upload_button(responsive_variant: :desktop)
        return nil unless @recensement.recensable?

        Galerie::Actions::Upload::ButtonComponent.new(responsive_variant:)
      end

      def upload_confirmation
        return nil unless @recensement.recensable?

        Galerie::Actions::Upload::ConfirmationComponent.new(
          attachments_path: conservateurs_attachments_path,
          recensement_id: @recensement.id,
          message:
            "Vous pouvez ajouter des photos récentes liées à ce recensement. " \
            "Merci de ne pas ajouter de photos d’archives.",
          redirect_path: close_path
        )
      end
    end
  end
end

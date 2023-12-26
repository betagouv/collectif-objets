# frozen_string_literal: true

module Galerie
  module Actions
    class ConservateurRecensement
      include Rails.application.routes.url_helpers

      delegate :close_path, :current_photo, :next_photo, :previous_photo, to: :@galerie

      def initialize(galerie:, recensement:)
        @galerie = galerie
        @recensement = recensement
      end

      def buttons(with_text: true)
        [
          download_button(with_text:),
          rotate_button(with_text:),
          destroy_button(with_text:),
          upload_button(with_text:)
        ].compact
      end

      def confirmations
        [destroy_confirmation, upload_confirmation].compact
      end

      def download_button(with_text: true)
        Galerie::Actions::Download::ButtonComponent.new(
          url: current_photo.download_url,
          with_text:
        )
      end

      def rotate_button(with_text: true)
        return nil if current_photo.nil?

        Galerie::Actions::Rotate::ButtonComponent.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: current_photo.lightbox_path,
          with_text:
        )
      end

      def destroy_button(with_text: true)
        return nil if current_photo.nil?

        Galerie::Actions::Destroy::ButtonComponent.new(with_text:)
      end

      def destroy_confirmation
        return nil if current_photo.nil?

        Galerie::Actions::Destroy::ConfirmationComponent.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: next_photo&.lightbox_path || previous_photo&.lightbox_path || close_path
        )
      end

      def upload_button(with_text: true)
        return nil unless @recensement.recensable?

        Galerie::Actions::Upload::ButtonComponent.new(with_text:)
      end

      def upload_confirmation
        return nil unless @recensement.recensable?

        Galerie::Actions::Upload::ConfirmationComponent.new(
          attachments_path: conservateurs_attachments_path,
          create_params: { recensement_id: @recensement.id },
          message:
            "Vous pouvez ajouter des photos récentes liées à ce recensement. " \
            "Merci de ne pas ajouter de photos d’archives.",
          redirect_path: close_path
        )
      end
    end
  end
end

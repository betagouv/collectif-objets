# frozen_string_literal: true

module Galerie
  module ActionGroups
    class ConservateurRecensement < Base
      delegate :close_path, :previous_photo, :next_photo, to: :@galerie

      def initialize(galerie:, recensement:)
        super(galerie:)
        @recensement = recensement
      end

      def rotate(responsive_variant: :desktop)
        return nil if current_photo.nil?

        Galerie::Actions::Rotate.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: current_photo.lightbox_path,
          responsive_variant:
        )
      end

      def destroy(responsive_variant: :desktop)
        return nil if current_photo.nil?

        Galerie::Actions::Destroy.new(
          attachment_path: conservateurs_attachment_path(current_photo.id),
          redirect_path: next_photo&.lightbox_path || previous_photo&.lightbox_path || close_path,
          responsive_variant:
        )
      end

      def upload(responsive_variant: :desktop)
        return nil unless @recensement.recensable?

        Galerie::Actions::Upload.new(
          attachments_path: conservateurs_attachments_path,
          recensement_id: @recensement.id,
          message:
            "Vous pouvez ajouter des photos récentes liées à ce recensement. " \
            "Merci de ne pas ajouter de photos d’archives.",
          redirect_path: close_path,
          responsive_variant:
        )
      end

      private

      def all(responsive_variant: :desktop)
        [
          download(responsive_variant:),
          rotate(responsive_variant:),
          destroy(responsive_variant:),
          upload(responsive_variant:)
        ].compact
      end
    end
  end
end

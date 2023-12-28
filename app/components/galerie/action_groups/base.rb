# frozen_string_literal: true

module Galerie
  module ActionGroups
    class Base
      include Rails.application.routes.url_helpers

      delegate :current_photo, to: :@galerie

      def initialize(galerie:)
        @galerie = galerie
      end

      def buttons(responsive_variant: :desktop)
        all(responsive_variant:).map(&:button_component)
      end

      def confirmations(responsive_variant: :desktop)
        all(responsive_variant:).map(&:confirmation_component).compact
      end

      def download(responsive_variant:)
        Galerie::Actions::Download.new(
          url: current_photo.download_url,
          responsive_variant:
        )
      end

      def upload = nil
      def rotate = nil
      def destroy = nil

      private

      def all(responsive_variant: :desktop)
        [download(responsive_variant:)]
      end
    end
  end
end

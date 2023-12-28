# frozen_string_literal: true

module Galerie
  module Actions
    class Basic
      include Rails.application.routes.url_helpers

      delegate :current_photo, to: :@galerie

      def initialize(galerie:)
        @galerie = galerie
      end

      def buttons(responsive_variant: :desktop)
        [download_button(responsive_variant:)]
      end

      def confirmations = []
      def upload_confirmation = nil
      def upload_button = nil

      def download_button(responsive_variant: :desktop)
        Galerie::Actions::Download::ButtonComponent.new(
          url: current_photo.download_url,
          responsive_variant:
        )
      end
    end
  end
end

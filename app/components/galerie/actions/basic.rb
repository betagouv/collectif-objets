# frozen_string_literal: true

module Galerie
  module Actions
    class Basic
      include Rails.application.routes.url_helpers

      delegate :current_photo, to: :@galerie

      def initialize(galerie:)
        @galerie = galerie
      end

      def buttons(with_text: true)
        [download_button(with_text:)]
      end

      def confirmations = []
      def upload_confirmation = nil
      def upload_button = nil

      def download_button(with_text: true)
        Galerie::Actions::Download::ButtonComponent.new(
          url: current_photo.download_url,
          with_text:
        )
      end
    end
  end
end

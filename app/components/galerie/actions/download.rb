# frozen_string_literal: true

module Galerie
  module Actions
    class Download
      include BaseConcern
      attr_reader :url

      def initialize(url:, responsive_variant: :desktop)
        @responsive_variant = responsive_variant
        @url = url
      end

      def button_component
        ButtonComponent.new(responsive_variant:, url:)
      end
    end
  end
end

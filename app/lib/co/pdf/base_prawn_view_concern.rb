# frozen_string_literal: true

module Co
  module Pdf
    module BasePrawnViewConcern
      extend ActiveSupport::Concern

      included do
        include Prawn::View
      end

      MARIANNE_FONT = {
        normal: Rails.public_path.join("dsfr/fonts_ttf/Marianne-Regular.ttf"),
        bold: Rails.public_path.join("dsfr/fonts_ttf/Marianne-Bold.ttf"),
        italic: Rails.public_path.join("dsfr/fonts_ttf/Marianne-Regular_Italic.ttf")
      }.freeze

      def set_default_font
        font_families.update("Marianne" => MARIANNE_FONT)
        font("Marianne")
      end
    end
  end
end

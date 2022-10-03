# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    attr_reader :objet

    def initialize(objet:)
      @objet = objet
      super
    end

    def tags
      @tags ||= [not_recensed_badge, missing_photos_badge].compact
    end

    def badges
      @badges ||= [analysed_badge, prioritaire_badge].compact
    end

    def recensement
      @recensement ||= objet.current_recensement
    end

    def main_photo_url
      return recensement.photos.first.variant(:medium) if recensement&.photos&.attached?

      return objet.image_urls.first if objet.image_urls.any?

      "images/illustrations/photo-manquante.png"
    end

    private

    def badge_struct
      Struct.new(:color, :text)
    end

    def not_recensed_badge
      badge_struct.new("warning", "Pas encore recensé") if recensement.nil?
    end

    def missing_photos_badge
      return nil unless recensement&.missing_photos?

      badge_struct.new(
        "warning", I18n.t("recensement.photos.missing")
      )
    end

    def analysed_badge
      return nil unless recensement&.analysed?

      badge_struct.new(
        "success",
        I18n.t("conservateurs.objet_card_component.analysed_badge")
      )
    end

    def prioritaire_badge
      return nil unless recensement&.prioritaire?

      badge_struct.new(
        "warning",
        I18n.t("conservateurs.objet_card_component.prioritaire_badge")
      )
    end
  end
end

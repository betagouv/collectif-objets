# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    attr_reader :objet

    def initialize(objet:)
      @objet = objet
      super
    end

    def desc_badges
      @desc_badges ||= [not_recensed_badge, peril_badge, missing_photos_badge].compact
    end

    def floating_badges
      @floating_badges ||= [analysed_badge, introuvable_badge].compact
    end

    def recensement
      @recensement ||= objet.current_recensement
    end

    def main_photo_url
      return recensement.photos.first.variant(:medium) if recensement&.photos&.attached?

      return objet.image_urls.first if objet.image_urls.any?

      "illustrations/photo-manquante.png"
    end

    private

    def badge_struct
      Struct.new(:color, :text)
    end

    def not_recensed_badge
      badge_struct.new("warning", "Pas encore recensé") if recensement.nil?
    end

    def peril_badge
      badge_struct.new("warning", "En péril") \
        if recensement&.analyse_or_original_value(:etat_sanitaire) == Recensement::ETAT_PERIL
    end

    def missing_photos_badge
      return nil unless recensement&.missing_photos?

      badge_struct.new(
        "warning", I18n.t("recensement.photos.taken_count", count: 0)
      )
    end

    def analysed_badge
      return nil unless recensement&.analysed?

      badge_struct.new(
        "success",
        I18n.t("conservateurs.objet_card_component.analysed_badge")
      )
    end

    def introuvable_badge
      return nil unless recensement&.absent?

      badge_struct.new(
        "warning",
        I18n.t("conservateurs.objet_card_component.introuvable_badge")
      )
    end
  end
end

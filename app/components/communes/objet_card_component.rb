# frozen_string_literal: true

module Communes
  class ObjetCardComponent < ViewComponent::Base
    attr_reader :objet

    with_collection_parameter :objet

    delegate :nom, :nom_courant, :commune, :edifice_nom, :current_recensement, :image_urls, to: :objet
    delegate :dossier, to: :current_recensement, allow_nil: true

    def initialize(objet:, badges: nil, display_recensement_photos: true)
      @objet = objet
      @badges = badges
      @display_recensement_photos = display_recensement_photos
      super
    end

    def badges
      @badges ||= [recensement_badge, analyse_notes_badge].compact
    end

    def truncated_nom
      truncate(nom || nom_courant, length: 30)
    end

    def main_photo_url
      return current_recensement.photos.first.variant(:medium) \
        if @display_recensement_photos && current_recensement&.photos&.attached?

      return image_urls.first if image_urls.any?

      "images/illustrations/photo-manquante.png"
    end

    protected

    def badge_struct
      Struct.new(:color, :text)
    end

    def recensement_badge
      return nil if dossier&.rejected? || dossier&.accepted?

      if current_recensement.present?
        badge_struct.new("success", "Recensé")
      else
        badge_struct.new("", "Pas encore recensé")
      end
    end

    def analyse_notes_badge
      return nil unless dossier&.rejected?

      badge_struct.new("info", "Commentaires") if current_recensement&.analyse_notes.present?
    end
  end
end

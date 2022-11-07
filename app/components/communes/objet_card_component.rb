# frozen_string_literal: true

module Communes
  class ObjetCardComponent < ViewComponent::Base
    def initialize(objet:)
      @objet = objet
      super
    end

    def call
      render ::ObjetCardComponent.new(objet:, badges:, main_photo_url: recensement_photo_url, path:)
    end

    private

    attr_reader :objet

    with_collection_parameter :objet

    delegate :current_recensement, to: :objet
    delegate :dossier, to: :current_recensement, allow_nil: true

    def path
      commune_objet_path(objet.commune, objet)
    end

    def badges
      @badges ||= [recensement_badge, analyse_notes_badge].compact
    end

    def recensement_photo_url
      current_recensement&.photos&.first&.variant(:medium)
    end

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

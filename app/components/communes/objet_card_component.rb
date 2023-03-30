# frozen_string_literal: true

module Communes
  class ObjetCardComponent < ViewComponent::Base
    include ObjetHelper

    def initialize(objet, commune:, recensement: nil, badges: nil)
      @objet = objet
      @recensement = recensement
      @commune = commune
      @badges = badges
      super
    end

    def call
      render ::ObjetCardComponent.new(objet, commune:, badges:, path:, main_photo_origin: :recensement_or_memoire)
    end

    private

    attr_reader :objet, :recensement, :commune

    delegate :dossier, to: :recensement, allow_nil: true

    def path
      commune_objet_path(commune, objet)
    end

    def badges
      @badges ||= [recensement_badge, analyse_notes_badge].compact
    end

    def badge_struct
      Struct.new(:color, :text)
    end

    def recensement_badge
      color, text = objet_recensement_badge_color_and_text(objet)
      badge_struct.new(color, text)
    end

    def analyse_notes_badge
      return nil unless dossier&.rejected?

      badge_struct.new("info", "Commentaires") if recensement&.analyse_notes.present?
    end
  end
end

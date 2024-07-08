# frozen_string_literal: true

module Communes
  class ObjetCardComponent < ViewComponent::Base
    include ObjetHelper

    def initialize(objet, commune:, recensement: nil)
      @objet = objet
      @recensement = recensement
      @commune = commune
      super
    end

    def call
      render ::ObjetCardComponent.new(objet, commune:, header_badges:, btn_text:, btn_class:, btn_path:,
                                             path:, main_photo_origin: :recensement_or_memoire)
    end

    def btn_text
      if readonly? # La commune a déjà recensé l'objet
        "Afficher"
      elsif recensement&.status == "draft" # Si la commune a commencé à recenser l'objet
        "Compléter"
      elsif recensement # La commune a déjà recensé l'objet
        "Modifier"
      else
        "Recenser"
      end
    end

    def btn_class
      "fr-btn fr-btn--sm fr-btn--icon-right fr-icon-arrow-right-line fr-enlarge-link fr-btn--secondary"
    end

    def btn_path
      return if readonly? || recensement.nil?

      edit_commune_objet_recensement_path(commune_id: commune.id, objet_id: objet.id, id: recensement.id)
    end

    private

    attr_reader :objet, :recensement, :commune

    delegate :dossier, to: :recensement, allow_nil: true

    def path
      commune_objet_path(commune, objet)
    end

    def readonly?
      objet.commune && commune&.status == "completed"
    end

    def header_badges
      [recensement_badge, analyse_notes_badge].compact
    end

    def badge_struct
      Struct.new(:color, :text)
    end

    def recensement_badge
      color, text = objet_recensement_badge_color_and_text(objet)
      return nil unless color && text

      badge_struct.new(color, text)
    end

    def analyse_notes_badge
      badge_struct.new("info", "Commentaires") if recensement&.analyse_notes.present?
    end
  end
end

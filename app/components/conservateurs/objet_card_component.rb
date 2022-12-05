# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    def initialize(objet, commune:, recensement: nil, can_analyse: false)
      @objet = objet
      @recensement = recensement
      @can_analyse = can_analyse
      @commune = commune
      super
    end

    def call
      render ::ObjetCardComponent.new(objet, commune:, badges:, main_photo_url: recensement_photo_url, path:, tags:)
    end

    private

    attr_reader :objet, :recensement, :can_analyse, :commune

    def path
      if can_analyse
        edit_conservateurs_objet_recensement_analyse_path(objet, recensement)
      else
        objet_path(objet)
      end
    end

    def badges
      return [] unless can_analyse

      @badges ||= [analysed_badge, prioritaire_badge].compact
    end

    def tags
      return [] unless can_analyse

      @tags ||= [not_recensed_badge, missing_photos_badge].compact
    end

    def recensement_photo_url
      recensement&.photos&.first&.variant(:medium)
    end

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

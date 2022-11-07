# frozen_string_literal: true

module Conservateurs
  class ObjetCardComponent < ViewComponent::Base
    def initialize(objet:)
      @objet = objet
      super
    end

    def call
      render ::ObjetCardComponent.new(objet:, badges:, main_photo_url: recensement_photo_url, path:, tags:)
    end

    attr_reader :objet

    with_collection_parameter :objet

    delegate :current_recensement, to: :objet

    def path
      if current_recensement
        edit_conservateurs_objet_recensement_analyse_path(objet, current_recensement)
      else
        objet_path(objet)
      end
    end

    def badges
      @badges ||= [analysed_badge, prioritaire_badge].compact
    end

    def tags
      @tags ||= [not_recensed_badge, missing_photos_badge].compact
    end

    def recensement_photo_url
      current_recensement&.photos&.first&.variant(:medium)
    end

    def badge_struct
      Struct.new(:color, :text)
    end

    def not_recensed_badge
      badge_struct.new("warning", "Pas encore recensé") if current_recensement.nil?
    end

    def missing_photos_badge
      return nil unless current_recensement&.missing_photos?

      badge_struct.new(
        "warning", I18n.t("recensement.photos.missing")
      )
    end

    def analysed_badge
      return nil unless current_recensement&.analysed?

      badge_struct.new(
        "success",
        I18n.t("conservateurs.objet_card_component.analysed_badge")
      )
    end

    def prioritaire_badge
      return nil unless current_recensement&.prioritaire?

      badge_struct.new(
        "warning",
        I18n.t("conservateurs.objet_card_component.prioritaire_badge")
      )
    end
  end
end

# frozen_string_literal: true

require "active_support/concern"

module Recensements
  module AnalyseConcern
    extend ActiveSupport::Concern

    ANALYSE_ACTION_SECURISER = "securiser"
    ANALYSE_ACTION_ENTRETENIR = "entretenir"
    ANALYSE_ACTION_RESTAURER = "restaurer"
    ANALYSE_ACTION_IDENTIFIER = "identifier"
    ANALYSE_ACTION_LOCALISER = "localiser"
    ANALYSE_ACTIONS = [
      ANALYSE_ACTION_SECURISER,
      ANALYSE_ACTION_ENTRETENIR,
      ANALYSE_ACTION_RESTAURER,
      ANALYSE_ACTION_IDENTIFIER,
      ANALYSE_ACTION_LOCALISER
    ].freeze

    ANALYSE_FICHE_VOL = "vol"
    ANALYSE_FICHE_SECURISATION = "securisation"
    ANALYSE_FICHE_INSECTES = "insectes"
    ANALYSE_FICHES = [
      ANALYSE_FICHE_VOL,
      ANALYSE_FICHE_SECURISATION,
      ANALYSE_FICHE_INSECTES
    ].freeze

    included do
      belongs_to :conservateur, optional: true
      validates :analyse_actions, intersection: { in: ANALYSE_ACTIONS }
      validates :analyse_fiches, intersection: { in: ANALYSE_FICHES }
      before_save :prevent_dull_analyse_override
    end

    def prevent_dull_analyse_override
      %i[etat_sanitaire etat_sanitaire_edifice securisation].each do |original_attribute_name|
        original_value = send(original_attribute_name)
        next if original_value.blank?

        analyse_attribute_name = "analyse_#{original_attribute_name}"
        analyse_value = send(analyse_attribute_name)
        send("#{analyse_attribute_name}=", nil) if analyse_value == original_value
      end
    end

    def analysed?
      analysed_at.present?
    end

    def analyse_overrides?
      %i[analyse_etat_sanitaire analyse_etat_sanitaire_edifice analyse_securisation].any? { send(_1).present? }
    end

    def analysable?
      objet.commune.completed? && dossier.submitted?
    end
  end
end

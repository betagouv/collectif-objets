# frozen_string_literal: true

require "active_support/concern"

module Recensements
  module AnalyseConcern
    extend ActiveSupport::Concern

    OVERRIDABLE_FIELDS = %i[etat_sanitaire etat_sanitaire_edifice securisation].freeze

    ANALYSE_FICHE_VOL = "vol"
    ANALYSE_FICHE_SECURISATION = "securisation"
    ANALYSE_FICHE_NUISIBLES = "nuisibles"
    ANALYSE_FICHES = [
      ANALYSE_FICHE_VOL,
      ANALYSE_FICHE_SECURISATION,
      ANALYSE_FICHE_NUISIBLES
    ].freeze

    included do
      belongs_to :conservateur, optional: true
      validates :analyse_fiches, intersection: { in: ANALYSE_FICHES }
      before_save :prevent_dull_analyse_override
    end

    def prevent_dull_analyse_override
      OVERRIDABLE_FIELDS.each do |original_attribute_name|
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

    def analyse_or_original_value(original_attribute_name)
      raise if OVERRIDABLE_FIELDS.exclude?(original_attribute_name.to_sym)

      analyse_attribute_name = "analyse_#{original_attribute_name}"
      analyse_attribute_value = send(analyse_attribute_name)
      return analyse_attribute_value if analyse_attribute_value.present?

      send(original_attribute_name)
    end

    def analyse_fiches_new_ids
      analyse_fiches.map(&:to_sym).map { Fiche::ANCIEN_IDS_MAPPING.fetch(_1) }
    end

    def analyse_fiches_objects
      analyse_fiches_new_ids.map { Fiche.load_from_id(_1) }
    end
  end
end

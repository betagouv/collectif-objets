# frozen_string_literal: true

require "active_support/concern"

module Recensements
  module BooleansConcern
    extend ActiveSupport::Concern

    def absent?
      localisation == Recensement::LOCALISATION_ABSENT
    end

    def déplacé?
      [
        Recensement::LOCALISATION_AUTRE_EDIFICE,
        Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE,
        Recensement::LOCALISATION_DEPLACEMENT_TEMPORAIRE
      ].include? localisation
    end

    def deplacement_definitif?
      localisation == Recensement::LOCALISATION_AUTRE_EDIFICE ||
        localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE
    end

    def deplacement_temporaire?
      localisation == Recensement::LOCALISATION_DEPLACEMENT_TEMPORAIRE
    end

    def edifice_initial?
      localisation == Recensement::LOCALISATION_EDIFICE_INITIAL
    end

    def missing_photos?
      recensable? && (edifice_initial? || deplacement_definitif?) && photos_count.zero?
    end

    def en_peril?
      [analyse_etat_sanitaire, etat_sanitaire].compact.first == Recensement::ETAT_PERIL
    end

    def en_mauvais_etat?
      [analyse_etat_sanitaire, etat_sanitaire].compact.first == Recensement::ETAT_MAUVAIS
    end

    def prioritaire?
      en_peril? || absent?
    end

    def analysable?
      commune.completed?
    end

    def mauvaise_securisation?
      securisation == Recensement::SECURISATION_MAUVAISE
    end

    def first? = commune.recensements.completed.empty?
  end
end

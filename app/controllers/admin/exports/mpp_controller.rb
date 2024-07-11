# frozen_string_literal: true

module Admin
  module Exports
    class MppController < BaseController
      def deplaces
        @objets = Objet.déplacés.examinés
                                .includes(:departement, :commune, :edifice, :recensements)
                                .includes(:nouveau_departement, :nouvelle_commune, :nouvel_edifice)
        @pagy, @objets = pagy(@objets)
      end

      def manquants
        @objets = Objet.manquants.examinés.includes(:departement, :commune, :recensements, recensements: :dossier)
        @pagy, @objets = pagy(@objets)
      end

      private

      def active_nav_links
        ["Administration"]
      end
    end
  end
end

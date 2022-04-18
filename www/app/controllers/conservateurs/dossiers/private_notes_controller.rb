# frozen_string_literal: true

module Conservateurs
  module Dossiers
    class PrivateNotesController < ApplicationController
      before_action :set_dossier, :set_commune, :restrict_access

      def update
        return unless @dossier.update(dossier_params)

        render_turbo_stream_update(
          "js-dossier-notes-conservateur-private-form",
          partial: "conservateurs/dossiers/private_notes/form",
          locals: { dossier: @dossier, saved: true }
        )
      end

      protected

      def set_dossier
        @dossier = Dossier.find(params[:dossier_id])
      end

      def set_commune
        @commune = @dossier.commune
      end

      def restrict_access
        if current_conservateur.nil?
          redirect_to root_path, alert: "Veuillez vous connecter"
        elsif current_conservateur.departements.exclude?(@dossier.departement)
          redirect_to root_path, alert: "Vous n'avez pas accès au département de ce dossier"
        end
      end

      def dossier_params
        params.require(:dossier).permit(:notes_conservateur_private)
      end
    end
  end
end

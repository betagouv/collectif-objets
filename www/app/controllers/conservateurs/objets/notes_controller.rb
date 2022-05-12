# frozen_string_literal: true

module Conservateurs
  module Objets
    class NotesController < ApplicationController
      before_action :set_objet, :set_commune, :restrict_access

      def update
        return unless @objet.update(objet_params)

        render_turbo_stream_update(
          "js-objet-notes-conservateur-form",
          partial: "conservateurs/objets/notes/form",
          locals: { objet: @objet, saved: true }
        )
      end

      protected

      def set_objet
        @objet = Objet.find(params[:objet_id])
      end

      def set_commune
        @commune = @objet.commune
      end

      def restrict_access
        if current_conservateur.nil?
          redirect_to root_path, alert: "Veuillez vous connecter"
        elsif current_conservateur.departements.exclude?(@commune.departement)
          redirect_to root_path, alert: "Vous n'avez pas accès au département de ce objet"
        end
      end

      def objet_params
        params.require(:objet).permit(:notes_conservateur).merge(
          conservateur_id: current_conservateur.id,
          notes_conservateur_at: Time.zone.now
        )
      end
    end
  end
end

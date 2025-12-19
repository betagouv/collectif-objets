# frozen_string_literal: true

module Recenseurs
  class DossiersController < BaseController
    before_action :set_commune
    before_action :set_dossier
    before_action :authorize_dossier

    def show; end

    private

    def set_dossier
      # Eager load all associations needed for RapportPresenter to prevent N+1 queries
      @dossier = @commune&.dossiers
        &.where&.not(status: :archived)
        &.includes(
          :conservateur,
          :commune,
          recensements: [
            { objet: :commune },
            :conservateur,
            :nouvelle_commune,
            { photos_attachments: { blob: :variant_records } }
          ]
        )
        &.first
    end

    def authorize_dossier
      if @dossier
        authorize(@dossier)
      else
        skip_authorization
      end
    end

    def active_nav_links = ["Examen du conservateur"]
  end
end

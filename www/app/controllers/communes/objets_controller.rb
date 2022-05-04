# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    def index
      @objets = Objet
        .where(commune: @commune)
        .with_photos_first
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])

      return if params[:recensement_saved].blank?

      @objets = @objets.without_recensement
      render(:recensement_saved)
    end

    def index_print
      raise if @commune.blank?

      @objets = Objet.where(commune: @commune)
    end
  end
end

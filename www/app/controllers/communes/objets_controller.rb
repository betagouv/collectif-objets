# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    def index
      @recensement_saved = params[:recensement_saved]

      @objets = Objet
        .where(commune: @commune)
        .with_photos_first
        .includes(:commune, recensements: %i[photos_attachments photos_blobs])

      @objets = @objets.without_recensement if @recensement_saved
    end

    def index_print
      raise if @commune.blank?

      @objets = Objet.where(commune: @commune)
    end
  end
end

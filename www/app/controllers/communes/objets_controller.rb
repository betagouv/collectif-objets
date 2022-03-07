# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    def index
      @recensement_saved = params[:recensement_saved]

      @objets = Objet
        .where(commune: @commune)
        .with_photos_first

      @objets = @objets.without_recensement if @recensement_saved
    end

    def index_print
      raise unless @commune.present?

      @objets = Objet.where(commune: @commune)
    end
  end
end

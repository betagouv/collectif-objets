# frozen_string_literal: true

module Communes
  class ObjetsController < BaseController
    def index
      @objets = Objet
        .where(commune: @commune)
        .with_photos_first
    end

    def index_print
      raise unless @commune.present?

      @objets = Objet.where(commune: @commune)
    end
  end
end

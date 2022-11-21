# frozen_string_literal: true

module Conservateurs
  class DossiersController < BaseController
    before_action :set_dossier, :set_commune

    def show; end

    protected

    def set_dossier
      @dossier = Dossier.find(params[:id])
      authorize(@dossier)
    end

    def set_commune
      @commune = @dossier.commune
    end
  end
end

# frozen_string_literal: true

module Communes
  class BaseController < ApplicationController
    before_action :set_commune, :restrict_access

    protected

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def restrict_access
      return true if current_user&.commune == @commune

      redirect_to root_path, alert: "Veuillez vous connecter"
    end
  end
end

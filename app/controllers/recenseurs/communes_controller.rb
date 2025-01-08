# frozen_string_literal: true

module Recenseurs
  class CommunesController < BaseController
    def index
      @pagy, @communes = pagy policy_scope(Commune).order(:departement_code, :nom)
      redirect_to [namespace, @communes.first] if @communes.load.size == 1
    end

    def show
      @commune = Commune.find(params[:id])
      authorize(@commune)
    end

    private

    def active_nav_links = %w[Communes]
  end
end

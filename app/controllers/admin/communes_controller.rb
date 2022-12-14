# frozen_string_literal: true

module Admin
  class CommunesController < BaseController
    def index
      @ransack = Commune.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @communes = pagy(
        @ransack.result.include_objets_count, items: 20
      )
    end

    def show
      @commune = Commune.find(params[:id])
    end
  end
end

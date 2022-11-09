# frozen_string_literal: true

module Api
  module V1
    class CommunesController < Api::V1::BaseController
      FIELDS = %w[code_insee nom status objets_count latitude longitude].freeze
      def index
        communes = Commune.include_objets_count.order(:code_insee).select(*FIELDS)
        communes = communes.where(departement_code: params[:departement_code]) if params[:departement_code]
        render json: communes.map { _1.slice(*FIELDS) }, cached: true
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    class DepartementsController < Api::V1::BaseController
      def index
        @departements = Departement.all.include_communes_count.include_objets_count
        render json: @departements.map(&:to_h), cached: true
      end
    end
  end
end

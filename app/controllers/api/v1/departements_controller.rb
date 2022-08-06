# frozen_string_literal: true

module Api
  module V1
    class DepartementsController < Api::V1::BaseController
      def index
        @departements = Co::Departements.models(include_communes_count: true, include_objets_count: true)
        render json: @departements.map(&:to_h), cached: true
      end
    end
  end
end

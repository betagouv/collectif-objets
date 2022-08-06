# frozen_string_literal: true

module Api
  module V1
    class CommunesController < Api::V1::BaseController
      def index
        @communes = Commune.include_objets_count.order(:code_insee).all.to_a
          .map { _1.attributes.slice("code_insee", "nom", "objets_count", "latitude", "longitude") }

        render json: @communes, cached: true
      end
    end
  end
end

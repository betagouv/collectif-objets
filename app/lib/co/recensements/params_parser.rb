# frozen_string_literal: true

module Co
  module Recensements
    class ParamsParser
      PERMITTED_PARAMS = %i[
        confirmation localisation recensable edifice_nom etat_sanitaire
        etat_sanitaire_edifice securisation notes skip_photos
      ].freeze

      def initialize(request_params)
        @request_params = request_params
      end

      def parse
        @params = @request_params
          .require(:recensement)
          .permit(*PERMITTED_PARAMS, photos: [])
        @params.merge!(skip_photos: @params[:skip_photos].present?)
        @params.merge!(confirmation: @params[:confirmation].present?)
        @params.merge!(recensable: @params[:recensable] == "true")
        @params.merge!(recensable: false) if absent?
        @params.merge!(not_recensable_overrides) unless @params[:recensable]
        @params
      end

      private

      def absent?
        @params[:localisation] == Recensement::LOCALISATION_ABSENT
      end

      def not_recensable_overrides
        {
          etat_sanitaire: nil,
          etat_sanitaire_edifice: nil,
          securisation: nil,
          photos: []
        }
      end
    end
  end
end

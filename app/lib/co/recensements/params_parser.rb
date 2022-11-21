# frozen_string_literal: true

module Co
  module Recensements
    class ParamsParser
      PERMITTED_PARAMS = %i[
        confirmation_sur_place
        localisation recensable edifice_nom
        etat_sanitaire etat_sanitaire_edifice
        securisation notes confirmation_pas_de_photos
      ].freeze

      def initialize(request_params)
        @request_params = request_params
      end

      def parse
        @params = permitted_params
        compact_photos
        parse_checkbox(:confirmation_sur_place)
        parse_checkbox(:confirmation_pas_de_photos)
        @params.merge!(confirmation_pas_de_photos: false) if @params[:photos]&.any?
        @params.merge!(recensable: @params[:recensable] == "true")
        @params.merge!(recensable: false) if absent?
        @params.merge!(not_recensable_overrides) unless @params[:recensable]
        @params
      end

      private

      def permitted_params
        @request_params
          .require(:recensement)
          .permit(*PERMITTED_PARAMS, photos: [])
      end

      def compact_photos
        @params[:photos] = @params[:photos]&.map(&:presence)&.compact
      end

      def parse_checkbox(name)
        return if @params[name].blank?

        @params.merge!(name => @params[name] == "1")
      end

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

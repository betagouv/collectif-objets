# frozen_string_literal: true

module Co
  module Recensements
    class AnalyseParamsParser
      PERMITTED_PARAMS = %i[
        analyse_etat_sanitaire analyse_etat_sanitaire_edifice
        analyse_securisation analyse_notes
      ].freeze

      def initialize(request_params)
        @request_params = request_params
      end

      def parse
        @params = @request_params
          .require(:recensement)
          .permit(*PERMITTED_PARAMS, analyse_fiches: [])
        @params.transform_values! { |v| v.is_a?(Array) ? v.map(&:presence).compact : v }
        @params.merge!(analysed_at: Time.zone.now)
        @params
      end
    end
  end
end

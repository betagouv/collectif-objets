# frozen_string_literal: true

module Admin
  module Exports
    class MppController < BaseController
      before_action :use_module, only: [:deplaces, :manquants]

      def deplaces; end
      def manquants; end

      private

      def use_module
        respond_to do |format|
          mod = "::Exports::Mpp::#{action_name.camelize}".constantize
          format.html do
            @headers = mod.headers
            @objets = mod.objets
            @pagy, @objets = pagy(@objets)
            @objets = @objets.collect { |objet| mod.values(objet) }
          end
          format.csv do
            filename = "Collectif_Objets_#{action_name}_#{Time.zone.now.strftime('%Y%m%d')}.csv"
            send_data mod.to_csv, filename:, type: "text/csv", disposition: :attachment
          end
        end
      end

      def active_nav_links
        ["Administration"]
      end
    end
  end
end

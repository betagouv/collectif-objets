# frozen_string_literal: true

module Conservateurs
  class CommunesSearchComponent < ViewComponent::Base
    include Pagy::Backend
    include Turbo::FramesHelper
    include ActionView::Helpers::FormOptionsHelper
    include CommuneHelper
    include DossierHelper

    def initialize(ransack:, departement:)
      @ransack = ransack
      @departement = departement
      super
    end

    def pagy_obj = pagy_result[0]
    def communes = pagy_result[1]

    # def order_link_path(key)
    #   conservateurs_departement_path(
    #     departement,
    #     status: filters.status,
    #     order: "#{key} #{order_link_dir(key)}"
    #   )
    # end
    #
    # def order_link_arrow(key)
    #   current_key, current_dir = order.split
    #   arrows = { "ASC" => "▼", "DESC" => "▲" }
    #   current_key == key ? arrows[current_dir] : "▿"
    # end

    private

    attr_reader :ransack, :departement

    # delegate :departement, :order, :filters, :arel, to: :ransack

    def pagy_result
      @pagy_result ||= pagy(arel)
    end

    # def order_link_dir(key)
    #   current_key, current_dir = order.split
    #   return "DESC" if current_key == key && current_dir == "ASC"
    #
    #   "ASC"
    # end
  end
end

# frozen_string_literal: true

module Co
  module Conservateurs
    class CommunesSearch
      attr_reader :filters, :order, :departement

      VALID_ORDER_KEYS = [
        "nom", "objets_count", "recensements_prioritaires_count",
        "communes.status", "dossiers.status"
      ].freeze
      VALID_ORDER_DIRS = %w[ASC DESC].freeze
      VALID_STATUS_FILTERS = (Commune.aasm.states.map(&:name).map(&:to_s) + ["all", nil]).freeze

      def initialize(departement, params)
        @departement = departement
        @params = params
        set_order
        set_filters
      end

      def set_order
        return @order = "recensements_prioritaires_count DESC" if params[:order].blank?

        @order = params[:order]
        key, dir = @order.split
        raise "invalid order value" if VALID_ORDER_KEYS.exclude?(key) || VALID_ORDER_DIRS.exclude?(dir)
      end

      def set_filters
        raise "invalid status filter" if VALID_STATUS_FILTERS.exclude?(params[:status].presence)

        filter_status = params[:status].presence || "completed"
        @filters = Struct.new(:status, :nom).new(filter_status, params[:nom])
      end

      def arel
        q = Commune
          .where(departement: @departement)
          .include_objets_count
          .include_objets_recenses_count
          .includes(:dossier)
          .where(@filters.status == "all" ? {} : { status: @filters.status })
        q = q.search_by_nom(@filters.nom) if @filters.nom&.strip&.present?
        q.order(@order)
      end

      protected

      attr_reader :params
    end
  end
end

# frozen_string_literal: true

module Conservateurs
  class CommunesSearchComponent < ViewComponent::Base
    include Pagy::Backend
    include Turbo::FramesHelper
    include ActionView::Helpers::FormOptionsHelper
    include CommuneHelper
    include DossierHelper

    delegate(
      :departement, :order, :filters, :arel,
      to: :communes_search
    )

    def initialize(communes_search:)
      @communes_search = communes_search
      super
    end

    def pagy_obj
      @pagy_obj ||= pagy_result[0]
    end

    def communes
      @communes ||= pagy_result[1]
    end

    def status_options_for_select
      options_for_select(
        %w[all inactive enrolled started completed]
          .map { [status_label(_1), _1] },
        filters.status
      )
    end

    def status_label(status_filter_key)
      [
        I18n.t("conservateurs.communes_search_component.status_options.#{status_filter_key}"),
        "(#{status_counts[status_filter_key] || 0})"
      ].join(" ")
    end

    def status_counts
      @status_counts ||= Commune.where(departement:)
        .status_value_counts.merge("all" => Commune.where(departement:).count)
    end

    def order_link_path(key)
      conservateurs_departement_path(
        departement,
        status: filters.status,
        order: "#{key} #{order_link_dir(key)}"
      )
    end

    def order_link_arrow(key)
      current_key, current_dir = order.split
      arrows = { "ASC" => "▼", "DESC" => "▲" }
      current_key == key ? arrows[current_dir] : "▿"
    end

    private

    attr_reader :communes_search

    def pagy_result
      @pagy_result ||= pagy(arel)
    end

    def order_link_dir(key)
      current_key, current_dir = order.split
      return "DESC" if current_key == key && current_dir == "ASC"

      "ASC"
    end
  end
end

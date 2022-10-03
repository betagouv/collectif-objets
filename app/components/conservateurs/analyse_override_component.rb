# frozen_string_literal: true

module Conservateurs
  class AnalyseOverrideComponent < ViewComponent::Base
    include ApplicationHelper
    include RecensementHelper

    attr_reader :original_attribute_name, :recensement

    def initialize(recensement:, original_attribute_name:, recensement_presenter: nil)
      @recensement = recensement
      @original_attribute_name = original_attribute_name
      @recensement_presenter = recensement_presenter
      super
    end

    def analyse_attribute_name
      "analyse_#{original_attribute_name}"
    end

    def recensement_presenter
      @recensement_presenter ||= RecensementPresenter.new(@recensement)
    end

    def analyse_attribute_value
      @recensement.send(analyse_attribute_name)
    end

    def overrode?
      analyse_attribute_value.present?
    end
  end
end

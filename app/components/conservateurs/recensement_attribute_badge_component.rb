# frozen_string_literal: true

module Conservateurs
  class RecensementAttributeBadgeComponent < ViewComponent::Base
    include ApplicationHelper
    include RecensementHelper

    attr_reader :recensement, :original_attribute_name

    def initialize(recensement, original_attribute_name)
      @recensement = recensement
      @original_attribute_name = original_attribute_name
      super
    end

    def analyse_attribute_name
      "analyse_#{original_attribute_name}"
    end

    def recensement_presenter
      @recensement_presenter ||= RecensementPresenter.new(@recensement)
    end

    def overrode?
      recensement.send(analyse_attribute_name).present?
    end

    def original_badge
      recensement_presenter.send(original_attribute_name)
    end

    def analyse_badge
      recensement_presenter.send(analyse_attribute_name)
    end
  end
end

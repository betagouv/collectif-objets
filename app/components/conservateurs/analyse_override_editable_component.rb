# frozen_string_literal: true

module Conservateurs
  class AnalyseOverrideEditableComponent < ApplicationComponent
    include ApplicationHelper
    include RecensementHelper

    attr_reader :form_builder, :original_attribute_name, :recensement

    def initialize(form_builder:, original_attribute_name:, recensement_presenter: nil)
      @form_builder = form_builder
      @recensement = form_builder.object
      @original_attribute_name = original_attribute_name
      super
    end

    def analyse_attribute_name
      "analyse_#{@original_attribute_name}"
    end

    def recensement_presenter
      @recensement_presenter ||= RecensementPresenter.new(@recensement)
    end

    def attribute_options_for_select
      all_options = send("#{original_attribute_name}_options_for_select")
      return all_options if analyse_attribute_value.present?

      all_options.filter { |_label, value| value != original_attribute_value }
    end

    def analyse_attribute_value
      @recensement.send(analyse_attribute_name)
    end

    def original_attribute_value
      @recensement.send(original_attribute_name)
    end

    def overrode?
      analyse_attribute_value.present?
    end
  end
end

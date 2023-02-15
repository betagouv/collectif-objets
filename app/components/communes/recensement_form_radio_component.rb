# frozen_string_literal: true

module Communes
  class RecensementFormRadioComponent < ViewComponent::Base
    attr_reader :form_builder, :attribute_name, :options

    def initialize(form_builder:, attribute_name:, options:, radio_button_options: {})
      @form_builder = form_builder
      @attribute_name = attribute_name
      @options = options
      @radio_button_options = radio_button_options
      super
    end

    def recensement
      @recensement ||= form_builder.object
    end

    def error_message
      @error_message ||= recensement.errors.messages_for(attribute_name)&.first
    end

    def analyse_attribute_name
      @analyse_attribute_name ||= "analyse_#{attribute_name}"
    end

    def analyse_attribute_value
      return nil unless %i[etat_sanitaire securisation].include?(attribute_name.to_sym)

      @analyse_attribute_value ||= recensement.send(analyse_attribute_name)
    end

    def analyse_override?
      analyse_attribute_value.present?
    end

    def radio_button_options
      return @radio_button_options unless analyse_override?

      @radio_button_options.deep_merge(
        disabled: true,
        data: { "force-disabled": true }
      )
    end
  end
end

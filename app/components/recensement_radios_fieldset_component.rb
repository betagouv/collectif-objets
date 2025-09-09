# frozen_string_literal: true

class RecensementRadiosFieldsetComponent < ApplicationComponent
  renders_one :legend
  renders_many :options, lambda { |value:, label:, **kwargs|
    form_builder.radio_button(field, value, **kwargs) +
      form_builder.label("#{field}_#{value}", label)
  }

  def initialize(form_builder:, field:)
    @form_builder = form_builder
    @field = field
    super
  end

  private

  def wizard = form_builder.object

  attr_accessor :form_builder, :field
end

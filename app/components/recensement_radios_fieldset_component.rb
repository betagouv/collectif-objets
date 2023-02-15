# frozen_string_literal: true

class RecensementRadiosFieldsetComponent < ViewComponent::Base
  renders_one :legend
  renders_many :options, lambda { |value:, label:, data: nil|
    form_builder.radio_button(field, value, data:) +
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

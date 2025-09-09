# frozen_string_literal: true

class CalloutWithCtaComponent < ApplicationComponent
  renders_one :text
  renders_one :cta

  def initialize(color: nil)
    @color = color
    super
  end

  def callout_color_class
    return nil if @color.nil?

    "fr-callout--#{@color}"
  end
end

# frozen_string_literal: true

class UnfoldComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :max_height_px, :button_text

  def initialize(max_height_px: 400, button_text: "Tout afficher…")
    @max_height_px = max_height_px
    @button_text = button_text
    super
  end
end

# frozen_string_literal: true

class UnfoldComponent < ApplicationComponent
  include ApplicationHelper

  attr_reader :max_height_px, :button_text, :folded

  def initialize(max_height_px: 400, button_text: "Tout afficher…", folded: true)
    @max_height_px = max_height_px
    @button_text = button_text
    @folded = folded
    super
  end
end

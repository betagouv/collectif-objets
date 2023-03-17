# frozen_string_literal: true

class ImpersonateCalloutComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(mode:, name:, toggle_path:)
    @mode = mode
    @name = name
    @toggle_path = toggle_path
    super
  end

  private

  attr_reader :mode, :name, :toggle_path

  def write?
    mode == :write
  end
end

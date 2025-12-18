# frozen_string_literal: true

class ImpersonateCalloutComponent < ApplicationComponent
  include ApplicationHelper

  def initialize(mode:, name:, toggle_path:, stop_path:)
    @mode = mode
    @name = name
    @toggle_path = toggle_path
    @stop_path = stop_path
    super
  end

  private

  attr_reader :mode, :name, :toggle_path, :stop_path

  def write?
    mode == :write
  end
end

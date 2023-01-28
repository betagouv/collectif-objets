# frozen_string_literal: true

module Demos
  class Base
    include Demos::FactoryBot

    def initialize(controller, variant: default_variant)
      @controller = controller
      @variant = variant
      @commune = build(:commune)
      @current_user ||= build(:user, commune: @commune)
    end

    attr_reader :current_user, :commune

    private

    def default_variant = :default
  end
end

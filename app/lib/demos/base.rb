# frozen_string_literal: true

module Demos
  class Base
    include Demos::FactoryBot

    def initialize(controller, variant: default_variant)
      @controller = controller
      @variant = variant
    end

    private

    def default_variant
      "default"
    end
  end
end

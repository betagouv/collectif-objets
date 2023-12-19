# frozen_string_literal: true

module Demos
  module FactoryBot
    def build(*, **)
      ::FactoryBot
        .build(*, **)
        .tap(&:readonly!)
        .tap { _1.assign_attributes(id: -1) }
    end
  end
end

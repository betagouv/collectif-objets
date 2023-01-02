# frozen_string_literal: true

module Demos
  module FactoryBot
    def build(*args, **kwargs)
      ::FactoryBot
        .build(*args, **kwargs)
        .tap(&:readonly!)
        .tap { _1.assign_attributes(id: -1) }
    end
  end
end

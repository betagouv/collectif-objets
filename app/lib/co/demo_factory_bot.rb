# frozen_string_literal: true

module Co
  module DemoFactoryBot
    def build(*args, **kwargs)
      FactoryBot
        .build(*args, **kwargs)
        .tap(&:readonly!)
        .tap { _1.assign_attributes(id: -1) }
    end
  end
end

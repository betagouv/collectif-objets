# frozen_string_literal: true

module CoreExtensions
  module Array
    module OptionalFilter
      def optional_filter
        filtered = filter { yield _1 }
        filtered.any? ? filtered : self
      end
    end
  end
end

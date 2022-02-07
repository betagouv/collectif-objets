module CoreExtensions
  module Array
    module OptionalFilter
      def optional_filter
        filtered = self.filter { yield _1 }
        filtered.any? ? filtered : self
      end
    end
  end
end

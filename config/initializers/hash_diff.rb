module HashDiff
  def diff(compare_to)
    self
      .reject { |k, v| compare_to[k] == v }
      .merge!(compare_to.reject { |k, _v| self.key?(k) })
  end
end

class Hash
  include HashDiff
end

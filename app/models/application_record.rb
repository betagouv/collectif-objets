class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def optional_filter(list)
    filtered = list.filter { yield _1 }
    filtered.any? ? filtered : list
  end
end

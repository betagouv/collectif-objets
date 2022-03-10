class DepartementFilter < Avo::Filters::SelectFilter
  self.name = 'Departement filter'

  def apply(request, query, value)
    if value
      query.where(departement: value.to_s)
    else
      query
    end
  end

  def options
    Commune.select(:departement).distinct.map(&:departement).compact.sort.map { [_1, _1] }.to_h
  end
end

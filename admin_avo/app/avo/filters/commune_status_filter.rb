class CommuneStatusFilter < Avo::Filters::SelectFilter
  self.name = 'Statut de la commune'

  def apply(request, query, value)
    case value
    when "empty"
      query.where(status: nil)
    when "enrolled"
      query.where(status: "enrolled")
    when "started"
      query.where(status: "started")
    when "completed"
      query.where(status: "completed")
    else
      query
    end
  end

  def options
    {
      'empty': 'Aucun statut',
      'enrolled': 'Commune Inscrite',
      'started': 'Recensement démarré',
      'completed': 'Recensement terminé',
    }
  end
end

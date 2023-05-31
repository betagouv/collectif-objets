# frozen_string_literal: true

module DepartementHelper
  def departements_options
    Departement.order(:code).map { [_1, _1.code] }
  end

  def departement_etat_objets_line_chart_data(stats)
    [
      { label: "En péril", backgroundColor: "rgba(179, 64, 1, 1)",
        data: [stats.etats_sanitaires_value_counts[Recensement::ETAT_PERIL]] },
      { label: "Mauvais état", backgroundColor: "rgba(133, 133, 247, 1)",
        data: [stats.etats_sanitaires_value_counts[Recensement::ETAT_MAUVAIS]] },
      { label: "État moyen", backgroundColor: "rgba(174, 173, 249, 1)",
        data: [stats.etats_sanitaires_value_counts[Recensement::ETAT_MOYEN]] },
      { label: "Bon état", backgroundColor: "rgba(205, 206, 252, 1)",
        data: [stats.etats_sanitaires_value_counts[Recensement::ETAT_BON]] }
    ]
  end
end

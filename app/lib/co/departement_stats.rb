# frozen_string_literal: true

module Co
  class DepartementStats
    def initialize(departement)
      @departement = departement
    end

    def objets_count
      @objets_count ||= Objet.where(lieu_actuel_departement_code: @departement).count
    end

    def objets_recenses_count
      @objets_recenses_count ||=
        Objet.where(lieu_actuel_departement_code: @departement).where.associated(:recensements).count
    end

    def objets_recenses_percentage
      return 0 if objets_count.zero?

      @objets_recenses_percentage ||= (objets_recenses_count.to_f / objets_count * 100).round
    end

    def communes_count
      @communes_count ||= Commune.where(departement: @departement).count
    end

    def communes_completed_count
      @communes_completed_count ||= Commune.where(departement: @departement).completed.count
    end

    def communes_completed_percentage
      return 0 if communes_count.zero?

      @communes_completed_percentage ||= (communes_completed_count.to_f / communes_count * 100).round
    end

    def etats_sanitaires_value_counts
      @etats_sanitaires_value_counts ||=
        Recensement.in_departement(@departement).etats_sanitaires_value_counts
    end
  end
end

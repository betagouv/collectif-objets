# frozen_string_literal: true

module Co
  class DepartementStats
    def initialize(departement)
      @departement = departement
    end

    attr_reader :departement

    delegate :code, :communes_count, to: :departement

    def objets_count
      @objets_count ||= Objet.in_departement(code).count
    end

    def objets_recenses_count
      @objets_recenses_count ||= Recensement.in_departement(code).count
    end

    def objets_recenses_percentage
      return 0 if objets_count.zero?

      @objets_recenses_percentage ||= (objets_recenses_count.to_f / objets_count * 100).round
    end

    def communes_completed_count
      @communes_completed_count ||= departement.communes.completed.count
    end

    def communes_completed_percentage
      return 0 if communes_count.zero?

      @communes_completed_percentage ||= (communes_completed_count.to_f / communes_count * 100).round
    end

    def etats_sanitaires_value_counts
      @etats_sanitaires_value_counts ||= departement.recensements.etats_sanitaires_value_counts
    end
  end
end

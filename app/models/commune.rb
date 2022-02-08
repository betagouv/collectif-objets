# frozen_string_literal: true

class Commune < ApplicationRecord
  has_many :objets, foreign_key: :commune_code_insee, primary_key: :code_insee

  def self.include_objets_count
    joins(
      %{
       LEFT OUTER JOIN (
         SELECT commune_code_insee, COUNT(*) objets_count
         FROM   objets
         GROUP BY commune_code_insee
       ) a ON a.commune_code_insee = communes.code_insee
     }
    ).select("communes.*, COALESCE(a.objets_count, 0) AS objets_count")
  end

  # rubocop:disable Metrics/AbcSize
  def self.select_best_objets(objets_arr)
    objets_arr
      .optional_filter { _1.image_urls.any? }
      .optional_filter { !_1.nom.include?(";") }
      .optional_filter { !_1.nom.match?(/[A-Z]/) }
      .optional_filter { _1.edifice_nom.present? }
      .optional_filter { _1.edifice_nom&.match?(/[A-Z]/) }
      .optional_filter { !_1.emplacement.present? }
  end
  # rubocop:enable Metrics/AbcSize

  def main_objet
    @main_objet ||=
      Commune.select_best_objets(objets.where.not(nom: nil).to_a).first
  end
end

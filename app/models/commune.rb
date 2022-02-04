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
end

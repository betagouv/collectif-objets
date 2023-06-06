# frozen_string_literal: true

class Departement < ApplicationRecord
  has_many :communes, dependent: :nullify, foreign_key: :departement_code, inverse_of: :departement
  has_many :objets, through: :communes
  has_many :dossiers, through: :communes
  has_many :recensements, through: :dossiers
  has_many :conservateur_roles, dependent: :destroy, foreign_key: :departement_code, inverse_of: :departement
  has_many :conservateurs, through: :conservateur_roles
  has_many :campaigns, dependent: :nullify, foreign_key: :departement_code, inverse_of: :departement
  has_many :pop_exports, dependent: :nullify, foreign_key: :departement_code, inverse_of: :departement

  def self.include_communes_count
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT "departement_code", COUNT(*) communes_count
          FROM communes
          GROUP BY "departement_code"
        ) a ON a."departement_code" = departements.code
      }
    ).select("departements.*, COALESCE(a.communes_count, 0) AS communes_count")
  end

  def self.include_objets_count
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT communes.departement_code, COUNT(objets.id) objets_count
          FROM objets
          LEFT JOIN communes ON communes.code_insee = objets."palissy_INSEE"
          GROUP BY communes.departement_code
        ) b ON b."departement_code" = departements.code
      }
    ).select("departements.*, COALESCE(b.objets_count, 0) AS objets_count")
  end

  def current_campaign
    campaigns.where("date_lancement <= ? AND date_fin >= ?", Time.zone.now.to_date, Time.zone.now.to_date).first
  end

  def to_s = [code, nom].join(" - ")
  alias display_name to_s
  def memoire_sequence_name = "memoire_photos_number_#{code}"
  def self.ransackable_attributes(_ = nil) = %w[code]
end

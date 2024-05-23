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

  scope :sorted, -> { order(:code) }

  def self.include_objets_count
    joins(
      %{
        LEFT OUTER JOIN (
          SELECT communes.departement_code, COUNT(objets.id) objets_count
          FROM objets
          LEFT JOIN communes ON communes.code_insee = objets.lieu_actuel_code_insee
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

  def self.parse_from_code_insee(code_insee)
    if code_insee&.length != 5
      Rails.logger.warn "le code INSEE '#{code_insee}' ne fait pas 5 caractères"
      return nil
    end

    code_insee.starts_with?("97") ? code_insee[0..2] : code_insee[0..1]
  end
end

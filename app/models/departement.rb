# frozen_string_literal: true

class Departement < ApplicationRecord
  CODES = %w[
    01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 21 22 23 24 25 26 27 28 29 2A 2B 30 31 32 33 34
    35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69
    70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 971 972 973 974 976
  ].freeze

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

# frozen_string_literal: true

class Conservateur < ApplicationRecord
  has_many :roles, class_name: "ConservateurRole", dependent: :destroy
  has_many :departements, through: :roles
  has_many :communes, through: :departements
  has_many :dossiers, dependent: :nullify
  has_many :recenseurs, through: :departements

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, password_length: 8..128

  scope :send_recap, -> { where(send_recap: true) }
  scope :with_departement, ->(d) { where("departement_codes @> ARRAY[?]::varchar[]", d) }

  attr_accessor :impersonating

  def to_s
    [first_name, last_name].join(" ")
  end
  alias full_name to_s

  # -------
  # RANSACK
  # -------

  def self.ransackable_attributes(_ = nil) = %w[email first_name last_name]
  def self.ransackable_associations(_ = nil) = %w[departements]
  def self.ransackable_scopes(_ = nil) = %i[with_departement]
  ransacker(:first_name, type: :string) { Arel.sql("unaccent(first_name)") }
  ransacker(:last_name, type: :string) { Arel.sql("unaccent(last_name)") }
end

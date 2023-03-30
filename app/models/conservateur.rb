# frozen_string_literal: true

class Conservateur < ApplicationRecord
  has_many :roles, class_name: "ConservateurRole", dependent: :destroy
  has_many :departements, through: :roles
  has_many :dossiers, dependent: :nullify

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, password_length: 8..128

  scope :with_departement, ->(d) { where("departement_codes @> ARRAY[?]::varchar[]", d) }

  attr_accessor :impersonating

  def to_s
    [first_name, last_name].join(" ")
  end
  alias full_name to_s

  def self.ransackable_attributes(_auth_object = nil)
    %w[email first_name last_name]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[departements]
  end

  def self.ransackable_scopes(_auth_object = nil)
    [:with_departement]
  end

  ransacker :first_name, type: :string do
    Arel.sql("unaccent(first_name)")
  end

  ransacker :last_name, type: :string do
    Arel.sql("unaccent(last_name)")
  end
end

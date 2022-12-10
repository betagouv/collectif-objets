# frozen_string_literal: true

class Conservateur < ApplicationRecord
  has_many :roles, class_name: "ConservateurRole", dependent: :destroy
  has_many :departements, through: :roles

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, password_length: 8..128

  scope :with_departement, ->(d) { where("departement_codes @> ARRAY[?]::varchar[]", d) }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_departement]
  end

  def to_s
    [first_name, last_name].join(" ")
  end
  alias full_name to_s
end

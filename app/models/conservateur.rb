# frozen_string_literal: true

class Conservateur < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable

  scope :with_departement, ->(d) { where("departements @> ARRAY[?]::varchar[]", d) }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_departement]
  end

  def to_s
    [first_name, last_name].join(" ")
  end
end

# frozen_string_literal: true

class ConservateurRole < ApplicationRecord
  belongs_to :conservateur
  belongs_to :departement, foreign_key: :departement_code, inverse_of: :conservateur_roles
end

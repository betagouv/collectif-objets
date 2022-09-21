# frozen_string_literal: true

class ObjetOverride < ApplicationRecord
  belongs_to :objet, foreign_key: :palissy_REF, primary_key: :palissy_REF, inverse_of: :overrides, optional: true
end

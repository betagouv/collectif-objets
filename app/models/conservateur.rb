# frozen_string_literal: true

class Conservateur < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable

  scope :with_departement, ->(d) { where("departements @> ARRAY[?]::varchar[]", d) }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_departement]
  end

  def rotate_login_token(valid_for: 24.hours)
    update(
      login_token: SecureRandom.hex(10),
      login_token_valid_until: Time.zone.now + valid_for
    )
  end

  def to_s
    [first_name, last_name].join(" ")
  end
end

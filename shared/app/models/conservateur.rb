# frozen_string_literal: true

class Conservateur < ApplicationRecord
  EMAIL_REGEX = \
    if Rails.configuration.x.environment_specific_name == "production"
      /culture\.gouv\.fr\z/
    else
      /((culture)|(beta))\.gouv\.fr\z/
    end

  devise :rememberable

  validates :email, format: { with: EMAIL_REGEX, message: "Seuls les emails en culture.gouv.fr sont acceptés" }

  scope :with_departement, ->(d) { where("departements @> ARRAY[?]::varchar[]", d) }

  def self.ransackable_scopes(_auth_object = nil)
    [:with_departement]
  end

  def rotate_login_token(valid_for: 60.minutes)
    update(
      login_token: SecureRandom.hex(10),
      login_token_valid_until: Time.zone.now + valid_for
    )
  end

  def to_s
    [first_name, last_name].join(" ")
  end
end

# frozen_string_literal: true

class User < ApplicationRecord
  SAFE_DOMAINS = %w[beta.gouv.fr dipasquale.fr failfail.fr mailcatch.com gmail.com].freeze

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :registerable

  belongs_to :commune, optional: true

  accepts_nested_attributes_for :commune

  attr_accessor :impersonating

  def rotate_login_token(valid_for: 60.minutes)
    update(
      login_token: SecureRandom.hex(10),
      login_token_valid_until: Time.zone.now + valid_for
    )
  end

  def password_required? = false
  def safe_email? = SAFE_DOMAINS.include?(email.split("@").last)
  def to_s = email.split("@")[0]
end

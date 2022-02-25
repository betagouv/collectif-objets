# frozen_string_literal: true

class User < ApplicationRecord
  ROLE_ADMIN = "admin"
  ROLE_MAIRIE = "mairie"
  ROLES = [ROLE_ADMIN, ROLE_MAIRIE].freeze

  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :registerable

  belongs_to :commune, optional: true
  validates :role, presence: true, inclusion: { in: ROLES }

  def password_required?
    false
  end

  def rotate_login_token(valid_for: 60.minutes)
    update(
      login_token: SecureRandom.hex(10),
      login_token_valid_until: Time.now + valid_for
    )
  end

  def admin?
    role == ROLE_ADMIN
  end

  def mairie?
    role == ROLE_MAIRIE
  end
end

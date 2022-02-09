# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :commune, optional: true

  def password_required?
    false
  end

  def rotate_login_token(valid_for: 60.minutes)
    update(
      login_token: SecureRandom.hex(10),
      login_token_valid_until: Time.now + valid_for
    )
  end
end

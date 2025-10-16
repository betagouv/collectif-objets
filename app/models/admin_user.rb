# frozen_string_literal: true

class AdminUser < ApplicationRecord
  devise :two_factor_authenticatable, :lockable,
         :recoverable, :rememberable, :validatable,
         :two_factor_backupable, otp_number_of_backup_codes: 10

  has_many :admin_comments, as: :author, dependent: :nullify

  validates :first_name, :last_name, presence: true

  delegate :generate_otp_secret, to: :class

  def to_s = [first_name, last_name].join(" ")

  def find_or_generate_otp_secret
    update(otp_secret: generate_otp_secret) unless otp_secret
    otp_secret
  end

  def enable_2fa!
    return if otp_required_for_login?

    backup_codes = generate_otp_backup_codes!
    otp_secret = find_or_generate_otp_secret
    update!(otp_required_for_login: true, otp_secret:)
    backup_codes
  end

  def disable_2fa!
    update!(otp_required_for_login: false, otp_secret: nil, otp_backup_codes: nil)
  end

  def remaining_otp_backup_codes
    (otp_backup_codes || []).size
  end
end

# frozen_string_literal: true

class AdminUser < ApplicationRecord
  devise :two_factor_authenticatable, :lockable,
         :recoverable, :rememberable, :validatable,
         :two_factor_backupable, otp_number_of_backup_codes: 10

  has_many :admin_comments, as: :author, dependent: :nullify

  validates :first_name, :last_name, presence: true

  def to_s = [first_name, last_name].join(" ")

  # Generate backup codes and return them in plain text (only time they're visible)
  def generate_otp_backup_codes!(count: 10)
    codes = count.times.map { generate_backup_code }
    self.otp_backup_codes = codes.map do |code|
      { code: BCrypt::Password.create(normalize_backup_code(code)), used_at: nil }
    end
    save!
    codes
  end

  # Validate and consume a backup code
  def invalidate_otp_backup_code!(code)
    return false if otp_backup_codes.blank?

    otp_backup_codes.each_with_index do |backup_code, index|
      next if backup_code["used_at"].present?

      next unless BCrypt::Password.new(backup_code["code"]) == normalize_backup_code(code)

      otp_backup_codes[index]["used_at"] = Time.current.iso8601
      save!
      return true
    end

    false
  end

  def otp_backup_codes_remaining
    otp_backup_codes.count { |code| code["used_at"].nil? }
  end

  private

  def generate_backup_code
    # Generates: XXXX-XXXX-XXXX
    3.times.collect { SecureRandom.alphanumeric(4) }.join("-").upcase
  end

  def normalize_backup_code(code)
    code.to_s.gsub(/[^A-Z0-9]/i, "").upcase
  end
end

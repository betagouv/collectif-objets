# frozen_string_literal: true

class SessionCodeGenerationError < StandardError; end

class SessionCode < ApplicationRecord
  LENGTH = 6
  FORMAT_REGEX = /^\d{#{LENGTH}}$/
  EXPIRE_AFTER = 60.minutes.freeze

  belongs_to :user

  def self.generate_random_code
    code = LENGTH.times.map { rand(0..9) }.join
    raise SessionCodeGenerationError, code unless code.match(FORMAT_REGEX)

    code
  end

  def expired?
    created_at < Time.zone.now - EXPIRE_AFTER
  end

  def used? = used_at.present?

  def mark_used! = update!(used_at: Time.zone.now)
end

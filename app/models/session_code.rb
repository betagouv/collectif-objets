# frozen_string_literal: true

class SessionCode < ApplicationRecord
  EXPIRE_AFTER = 60.minutes.freeze

  belongs_to :user

  def self.generate_random_code
    length = 6
    rand(10.pow(length - 1)...10.pow(length)).to_s
  end

  def expired?
    created_at < Time.zone.now - EXPIRE_AFTER
  end

  def used? = used_at.present?

  def mark_used! = update!(used_at: Time.zone.now)
end

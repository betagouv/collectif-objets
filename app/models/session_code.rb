# frozen_string_literal: true

class SessionCode < ApplicationRecord
  EXPIRE_AFTER = 1.day.freeze

  belongs_to :user

  before_create :generate_code

  delegate :random_code, to: :class

  def self.random_code
    length = 6
    rand(10.pow(length - 1)...10.pow(length)).to_s
  end

  def expired?
    created_at < Time.zone.now - EXPIRE_AFTER
  end

  def valid_until = (created_at || Time.zone.now) + EXPIRE_AFTER

  def used? = used_at.present?

  def mark_used! = update!(used_at: Time.zone.now)

  private

  def generate_code = self.code = random_code
end

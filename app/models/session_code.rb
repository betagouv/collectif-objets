# frozen_string_literal: true

class SessionCode < ApplicationRecord
  LENGTH = 6
  EXPIRE_AFTER = 1.day.freeze

  belongs_to :user

  scope :used, -> { where.not(used_at: nil) }
  scope :unused, -> { where(used_at: nil) }
  scope :valid, -> { unused.where(created_at: EXPIRE_AFTER.ago..) }

  before_create :generate_code

  delegate :random_code, to: :class

  def self.random_code
    rand((10.pow(LENGTH - 1))...(10.pow(LENGTH))).to_s
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

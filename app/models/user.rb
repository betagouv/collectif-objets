# frozen_string_literal: true

class User < ApplicationRecord
  SAFE_DOMAINS = %w[beta.gouv.fr dipasquale.fr failfail.fr mailcatch.com gmail.com].freeze

  devise :timeoutable, timeout_in: 3.months

  belongs_to :commune, optional: true

  accepts_nested_attributes_for :commune

  has_many :session_codes, dependent: :destroy

  attr_accessor :impersonating

  def safe_email? = SAFE_DOMAINS.include?(email.split("@").last)
  def to_s = email.split("@")[0]

  def last_session_code = session_codes.order(created_at: :desc).first
end

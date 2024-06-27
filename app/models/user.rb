# frozen_string_literal: true

class User < ApplicationRecord
  devise :timeoutable, timeout_in: 3.months

  belongs_to :commune, optional: true

  accepts_nested_attributes_for :commune

  has_one :session_code, -> { valid.order(created_at: :desc) }, dependent: :destroy, inverse_of: :user

  attr_accessor :impersonating

  validates :email, presence: true, uniqueness: true

  def to_s = email.split("@")[0]
end

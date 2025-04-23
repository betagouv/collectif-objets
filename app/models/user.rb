# frozen_string_literal: true

class User < ApplicationRecord
  include SessionCodeAuthenticatable

  devise :timeoutable, timeout_in: 3.months

  belongs_to :commune, optional: true

  accepts_nested_attributes_for :commune

  attr_accessor :impersonating

  validates :email, presence: true, uniqueness: true

  def to_s = email.split("@")[0]
end

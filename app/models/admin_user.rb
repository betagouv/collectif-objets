# frozen_string_literal: true

class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :admin_comments, as: :author, dependent: :nullify

  validates :first_name, :last_name, presence: true

  def to_s = [first_name, last_name].join(" ")
end

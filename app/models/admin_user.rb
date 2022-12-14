# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :active_admin_comments, as: :author, dependent: :nullify

  def to_s
    email.split("@")[0].gsub("_", " ").gsub("-", " ").gsub(".", " ").capitalize
  end

  def first_name
    to_s.split[0]
  end
end

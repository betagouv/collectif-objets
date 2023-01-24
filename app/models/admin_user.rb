# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :active_admin_comments, as: :author, dependent: :nullify

  validates :first_name, :last_name, presence: true

  def to_s
    [first_name, last_name].join(" ")
  end
end

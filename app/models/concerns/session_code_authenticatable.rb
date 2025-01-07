# frozen_string_literal: true

module SessionCodeAuthenticatable
  extend ActiveSupport::Concern

  included do
    has_one :session_code, -> { valid.order(created_at: :desc) }, dependent: :destroy, as: :record
    has_many :session_codes, dependent: :destroy # To destroy expired codes
  end
end

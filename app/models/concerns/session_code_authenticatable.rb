# frozen_string_literal: true

module SessionCodeAuthenticatable
  extend ActiveSupport::Concern

  included do
    has_one :session_code, -> { valid.order(created_at: :desc) }, dependent: :destroy, as: :record, inverse_of: :record
    has_many :session_codes, as: :record, dependent: :destroy # To destroy expired codes
  end

  class_methods do
    def authenticate_by(email:, code:)
      SessionAuthentication.authenticate_by(email:, code:, model: self)
    end
  end
end

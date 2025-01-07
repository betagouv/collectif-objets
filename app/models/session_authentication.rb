# frozen_string_literal: true

# Models a User's attempt to sign in using a SessionCode
# exclusively used in Users::SessionsController
class SessionAuthentication
  include ActiveModel::Validations

  # the order of these validations is important
  validates :email, presence: true
  validates :code, presence: true
  validate  :validate_resource_found, :validate_code_format, :validate_codes_match, :validate_code_not_expired

  delegate :session_code, to: :authenticatable

  class << self
    def authenticate_by(email:, code:, model:)
      new(email:, code:, model:).authenticate
    end
  end

  def initialize(email:, code:, model:)
    @email = email.to_s.strip
    @code = code.gsub(/\D+/, "")
    @model = model
  end

  def authenticate
    prevent_timing_attacks
    if valid?
      session_code.mark_used!
      authenticatable
    else
      [nil, errors.full_messages.to_sentence]
    end
  end

  def authenticatable
    @authenticatable ||= @model.find_by(email:)
  end

  private

  attr_reader :email, :code

  def validate_resource_found
    return if authenticatable.persisted?

    errors.add(
      :email,
      :not_found,
      message: "Aucun compte trouvé pour cet email"
    )
  end

  def validate_code_format
    return if errors.any? || SessionCode.valid_format?(code)

    errors.add(
      :code,
      :invalid,
      message: "Le code de connexion est composé de #{SessionCode::LENGTH} chiffres exactement. " \
               "Vérifiez que vous n'avez pas copié deux fois le même chiffre."
    )
  end

  def validate_codes_match
    return if errors.any?

    return if session_code.present? && session_code.code == code

    errors.add(
      :code,
      :mismatch,
      message: "Code de connexion incorrect. " \
               "Vérifiez que vous avez bien recopié le code et qu'il provient bien du dernier mail envoyé."
    )
  end

  def validate_code_not_expired
    return if errors.any?

    return unless session_code.expired?

    errors.add(
      :code,
      :expired,
      message: "Le code de connexion n'est plus valide, veuillez en demander un nouveau."
    )
  end

  def prevent_timing_attacks
    sleep(rand(0.5..1)) if Rails.env.production?
  end
end

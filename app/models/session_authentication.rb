# frozen_string_literal: true

# Models a User's attempt to sign in using a SessionCode
# exclusively used in Users::SessionsController
class SessionAuthentication
  include ActiveModel::Validations

  # the order of these validations is important
  validates :email, presence: true
  validates :code, presence: true
  validates :user, presence: { message: "Aucun utilisateur trouvé pour cet email" }
  validate :validate_code_format, :validate_codes_match, :validate_code_not_expired, :validate_code_not_used

  def initialize(email, code)
    @email = email
    @code = code
  end

  def authenticate(&sign_in_block)
    sleep(rand(0.5..1)) if Rails.env.production? # To prevent timing attacks
    return false unless valid?

    return false unless sign_in_block.call(user)

    last_session_code.mark_used!
    true
  end

  def user
    @user ||= User.find_by(email:)
  end

  def error_message = errors.map(&:message).to_sentence

  private

  attr_reader :email, :code

  delegate :last_session_code, to: :user, allow_nil: true

  def cleaned_code
    @cleaned_code ||= code.gsub(/\s+/, "")
  end

  def validate_code_format
    return if errors.any? || cleaned_code.match(SessionCode::FORMAT_REGEX)

    errors.add(
      :code,
      :invalid_format,
      message: "Le code de connexion est composé de 6 chiffres exactement. " \
               "Vérifiez que vous n’avez pas copié deux fois le même chiffre."
    )
  end

  def validate_codes_match
    return if errors.any?

    return if last_session_code.present? && last_session_code.code == cleaned_code

    errors.add(
      :code,
      :mismatch,
      message: "Code de connexion incorrect. " \
               "Vérifiez que vous avez bien recopié le code et qu’il provient bien du dernier mail envoyé."
    )
  end

  def validate_code_not_used
    return if errors.any?

    return unless last_session_code.used?

    errors.add :code, :used, message: "Code de connexion déjà utilisé"
  end

  def validate_code_not_expired
    return if errors.any?

    return unless last_session_code.expired?

    errors.add :code, :expired, message: "Le code de connexion n'est plus valide, " \
                                         "veuillez en redemander un en cliquant sur le bouton ci-dessous"
  end
end

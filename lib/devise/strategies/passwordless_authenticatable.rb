# frozen_string_literal: true

require "devise/strategies/authenticatable"

module Devise
  module Strategies
    class PasswordlessAuthenticatable < Authenticatable
      # rubocop:disable Metrics/AbcSize
      def authenticate!
        return unless params[:user].present?

        user = User.find_by(email: params[:user][:email])

        if user&.update(login_token: SecureRandom.hex(10),
                        login_token_valid_until: Time.now + 60.minutes)
          url = Rails.application.routes.url_helpers.sign_in_with_token_url(login_token: user.login_token)

          UserMailer.validate_email(user, url).deliver_now

          fail!("An email was sent to you with a magic link.")
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end

Warden::Strategies.add(:passwordless_authenticatable, Devise::Strategies::PasswordlessAuthenticatable)

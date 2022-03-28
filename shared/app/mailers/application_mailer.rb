# frozen_string_literal: true

module MailerHelper
  def png_base64(path)
    File.open(Rails.root.join(path), "rb") do |img|
      "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
    end
  end
end

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("collectifobjets@beta.gouv.fr", "Collectif Objets")
  layout "mailer"

  helper MailerHelper

  protected

  def user_login_url(user)
    if user.magic_token.present?
      "#{Rails.configuration.x.www_base_url}/magic-authentication?magic-token=#{user.magic_token}"
    else
      "#{Rails.configuration.x.www_base_url}/users/sign_in"
    end
  end
end

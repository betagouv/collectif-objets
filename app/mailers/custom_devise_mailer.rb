# frozen_string_literal: true

class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: "devise/mailer"

  def reset_password_instructions(record, token, opts = {})
    @token = token
    if record.last_sign_in_at?
      devise_mail(record, :reset_password_instructions, opts)
    else
      devise_mail(record, :define_password_instructions, opts)
    end
  end
end

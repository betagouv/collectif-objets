# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include ActionMailer::Html2Text # Generate a text email based on the HTML

  default from: email_address_with_name(CONTACT_EMAIL, "Collectif Objets")
  layout "application_mailer"
  prepend_view_path "app/mailer_views"
end

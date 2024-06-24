# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include ActionMailer::Html2Text # Generate a text email based on the HTML

  default from: email_address_with_name(CONTACT_EMAIL, I18n.t("application_mailer_layout.project_name"))
  layout "application_mailer"
  prepend_view_path "app/mailer_views"
end

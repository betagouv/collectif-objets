# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(CONTACT_EMAIL, "Collectif Objets")
  layout "application_mailer"
  prepend_view_path "app/mailer_views"

  # rubocop:disable Rails/OutputSafety
  def line_breaks_to_br(content)
    return content if content.blank?

    content.gsub("\n", "<br />").html_safe
  end
  helper_method :line_breaks_to_br
  # rubocop:enable Rails/OutputSafety
end

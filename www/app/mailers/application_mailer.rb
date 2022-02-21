# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("collectifobjets@beta.gouv.fr", "Collectif Objets")
  layout "mailer"
end

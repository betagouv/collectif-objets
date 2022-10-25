# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def sanity_check_alert(email, commune, text)
    @text = text
    @commune = commune
    mail(
      to: email,
      subject: "Admin - Sanity Check Alert - #{commune}"
    )
  end
end

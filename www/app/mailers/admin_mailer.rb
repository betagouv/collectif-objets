# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def emails_report(email, report)
    raise unless email.ends_with?(".gouv.fr")

    @report_data = report
    mail(
      to: email,
      subject: "Admin - Contacts SIB - Rapport"
    )
  end
end

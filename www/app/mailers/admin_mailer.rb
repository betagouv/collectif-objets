# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def emails_report(report)
    @report_data = report
    mail(
      to: "collectifobjets@beta.gouv.fr",
      subject: "Admin - Contacts SIB - Rapport"
    )
  end
end

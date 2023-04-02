# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def sanity_check_alert(email, commune, text)
    @text = text
    @commune = commune
    @title = "#{title_prefix} - Sanity Check Alert - #{commune}"
    mail to: email, subject: title
  end

  def campaign_planned(conservateur, campaign)
    @conservateur = conservateur
    @campaign = campaign
    @subject = "#{title_prefix} - Campagne planifiée par un conservateur dans le #{campaign.departement}"
    mail to: "collectifobjets@beta.gouv.fr", subject: @subject
  end

  private

  def title_prefix
    "CO Admin [#{Rails.configuration.x.environment_specific_name}]"
  end
end

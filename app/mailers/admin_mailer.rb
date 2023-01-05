# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def sanity_check_alert(email, commune, text)
    @text = text
    @commune = commune
    mail to: email, subject: "Admin - Sanity Check Alert - #{commune}"
  end

  def campaign_planned(conservateur, campaign)
    @conservateur = conservateur
    @campaign = campaign
    mail to: "collectifobjets@beta.gouv.fr",
         subject: "Admin - Campagne planifiée par un conservateur - #{campaign.departement}"
  end
end

# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def sanity_check_alert
    @email, @commune, @text = params.values_at(:email, :commune, :text)
    mail to: @email, subject: [title_prefix, "Sanity Check Alert", @commune].compact.join(" - ")
  end

  def campaign_planned(conservateur, campaign)
    @conservateur = conservateur
    @campaign = campaign
    @subject = "#{title_prefix} - Campagne planifiée par un conservateur dans le #{campaign.departement}"
    mail to: CONTACT_EMAIL, subject: @subject
  end

  private

  def title_prefix = "CO Admin [#{Rails.configuration.x.environment_specific_name}]".freeze
end

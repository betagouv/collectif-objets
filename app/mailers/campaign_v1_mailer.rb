# frozen_string_literal: true

class CampaignV1Mailer < ApplicationMailer
  layout "campaign_v1_mailer"
  before_action :set_campaign_commune_and_user
  default(
    to: -> { @user.email },
    from: -> { email_address_with_name("collectifobjets@beta.gouv.fr", @campaign.sender_name) },
    reply_to: "support@collectif-objets.beta.gouv.fr"
  )

  MAIL_NAMES = (
    Campaign::STEPS +
    %w[relance1_enrolled relance2_enrolled relance3_enrolled]
  ).freeze

  MAIL_NAMES.each do |name|
    define_method "#{name}_email" do
      mail_with_subject(
        t(
          "campaign_v1_mailer.#{name}_email.subject",
          nom_commune: @commune.nom,
          dans_departement: @departement.dans_nom,
          count: @commune.objets.count
        )
      )
    end
  end

  private

  def mail_with_subject(subject)
    mail(subject: "[#{@campaign.nom_drac}] #{subject}")
  end

  def set_campaign_commune_and_user
    @campaign = params[:campaign]
    @commune = params[:commune]
    @user = params[:user]
    @departement = @campaign.departement
  end
end

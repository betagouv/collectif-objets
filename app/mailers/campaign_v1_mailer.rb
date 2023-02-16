# frozen_string_literal: true

class CampaignV1Mailer < ApplicationMailer
  layout "campaign_v1_mailer"
  before_action :set_campaign_commune_and_user
  default \
    to: -> { @user.email },
    from: -> { email_address_with_name("collectifobjets@beta.gouv.fr", @campaign.sender_name) },
    reply_to: -> { @commune.support_email(role: :user) }

  MAIL_NAMES = (
    %w[lancement] +
    %w[relance1_inactive relance2_inactive relance3_inactive fin_inactive] +
    %w[relance2_started relance3_started fin_started] +
    %w[relance2_to_complete relance3_to_complete fin_to_complete]
  ).freeze

  MAIL_NAMES.each do |name|
    define_method "#{name}_email" do
      mail(subject: "[DRAC #{@campaign.nom_drac}] #{t("campaign_v1_mailer.#{name}.subject", **i18n_args)}")
    end
  end

  # rubocop:disable Rails/OutputSafety
  def ct(key, **kwargs)
    I18n.t("campaign_v1_mailer.#{key}", **i18n_args.merge(**kwargs)).html_safe
  end
  helper_method :ct
  # rubocop:enable Rails/OutputSafety

  def tt(key, **kwargs)
    I18n.t("campaign_v1_mailer.#{key}", **i18n_args.merge(**kwargs)).gsub("<b>", "").gsub("</b>", "")
  end
  helper_method :tt

  private

  def mail_with_subject(subject); end

  def set_campaign_commune_and_user
    @campaign = params[:campaign]
    @commune = params[:commune]
    @user = params[:user]
    @departement = @campaign.departement
  end

  def i18n_args
    @i18n_args ||= {
      nom_drac: @campaign.nom_drac,
      dans_departement: @departement.dans_nom,
      nom_commune: @commune.nom,
      count: @commune.objets.size,
      nombre_communes: @campaign.communes.size,
      date_lancement: I18n.l(@campaign.date_lancement, format: :long_with_weekday),
      date_fin: I18n.l(@campaign.date_fin, format: :long_with_weekday),
      fin_dans_n_semaines: Time.zone.today.upto(@campaign.date_fin).count / 7,
      fin_dans_n_jours: Time.zone.today.upto(@campaign.date_fin).count
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end

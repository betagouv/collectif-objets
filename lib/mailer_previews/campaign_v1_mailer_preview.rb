# frozen_string_literal: true

class CampaignV1MailerPreview < ApplicationMailerPreview
  CampaignV1Mailer::MAIL_NAMES.each do |name|
    define_method "#{name}_email" do
      @commune_status = name.include?("started") || name.include?("to_complete") ? "started" : "inactive"
      CampaignV1Mailer.with(user:, commune:, campaign:).send("#{name}_email")
    end
  end

  protected

  def user
    @user ||= build :user, email: "mairie@thoiry.fr", login_token: "fakecode"
  end

  def commune
    commune ||= build \
      :commune,
      nom: "Thoiry", code_insee: "23300", departement_code: "23", status: @commune_status,
      objets: build_list(:objet, 10)
    def commune.highlighted_objet = objets.first
    @commune ||= commune
  end

  def campaign
    @campaign ||= build :campaign, communes: build_list(:commune, 10)
  end
end

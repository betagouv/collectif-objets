# frozen_string_literal: true

class CampaignV1MailerPreview < ApplicationMailerPreview
  CampaignV1Mailer::MAIL_NAMES.each do |name|
    define_method "#{name}_email" do
      @commune_status = name.include?("started") || name.include?("to_complete") ? "started" : "inactive"
      CampaignV1Mailer.with(user:, commune:, campaign:).send("#{name}_email")
    end
  end

  private

  attr_reader :user, :commune, :campaign

  def user
    @user ||= commune.users.first
  end

  def commune
    @commune ||= campaign.communes.first
  end

  def campaign
    @campaign ||= Campaign.first
  end
end

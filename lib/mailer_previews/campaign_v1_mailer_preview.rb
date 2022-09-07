# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength, Style/OpenStructUse

class CampaignV1MailerPreview < ActionMailer::Preview
  CampaignV1Mailer::MAIL_NAMES.each do |name|
    define_method "#{name}_email" do
      @commune_status = name.include?("started") || name.include?("to_complete") ? "started" : "inactive"
      CampaignV1Mailer.with(user:, commune:, campaign:).send("#{name}_email")
    end
  end

  protected

  def user
    @user ||= User.new(email: "mairie@thoiry.fr", login_token: "fakecode").tap(&:readonly!)
  end

  def commune
    commune ||= Commune.new(
      nom: "Thoiry", code_insee: "23300", departement_code: "23", status: @commune_status
    ).tap(&:readonly!)

    def commune.objets
      OpenStruct.new(count: 20)
    end

    def commune.highlighted_objet
      OpenStruct.new(
        image_urls: [],
        nom_formatted: "Grande table Louis XVI",
        edifice_nom_formatted: "Église St-Baptiste",
        emplacement: "Sacristie"
      )
    end
    @commune ||= commune
  end

  def campaign
    campaign = FactoryBot.build(:campaign)
    def campaign.communes
      OpenStruct.new(count: 304)
    end
    @campaign ||= campaign
  end
end

# rubocop:enable Metrics/MethodLength, Style/OpenStructUse

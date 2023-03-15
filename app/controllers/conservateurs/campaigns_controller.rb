# frozen_string_literal: true

module Conservateurs
  class CampaignsController < BaseController
    include CampaignsControllerConcern

    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :set_campaign, :authorize_campaign,
                  only: %i[show mail_previews edit edit_recipients update_recipients update_status update destroy]
    before_action :set_excluded_communes, only: %i[show update_status]
    before_action :redirect_planned_campaign, only: %i[edit_recipients]
    after_action :enqueue_admin_mail, only: %i[update_status]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def new
      @departement = Departement.find(params[:departement_id])
      @campaign = Campaign.new(departement: @departement)
      authorize(@campaign)
    end

    def enqueue_admin_mail
      return if @status_event != "plan" || !@success

      AdminMailer.campaign_planned(current_conservateur, @campaign).deliver_later
    end

    private

    def routes_prefix = :conservateurs

    def after_destroy_path
      conservateurs_departement_path(@campaign.departement)
    end

    def authorize_campaign
      authorize(@campaign)
    end

    def active_nav_links = ["Mes départements", @departement.to_s]
  end
end

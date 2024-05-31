# frozen_string_literal: true

module Conservateurs
  class CampaignsController < BaseController
    include CampaignsControllerConcern

    # rubocop:disable Rails/LexicallyScopedActionFilter
    # Certaines actions sont définies dans le concern partagés par admins et conservateurs
    before_action :authorize_campaign, except: %i[new create]
    after_action :enqueue_admin_mail, only: %i[update_status]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def new
      @departement = Departement.find(params[:departement_id])
      @campaign = Campaign.new(departement: @departement)
      authorize(@campaign)
    end

    private

    def enqueue_admin_mail
      return if @status_event != "plan" || !@success

      AdminMailer.campaign_planned(current_conservateur, @campaign).deliver_later
    end

    def routes_prefix = :conservateurs
    def after_destroy_path = conservateurs_departement_path @campaign.departement
    def authorize_campaign = authorize @campaign
    def active_nav_links = ["Mes départements", @departement.to_s]
  end
end

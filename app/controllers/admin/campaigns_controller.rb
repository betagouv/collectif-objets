# frozen_string_literal: true

module Admin
  class CampaignsController < BaseController
    include CampaignsControllerConcern

    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action \
      :set_campaign,
      only: %i[
        show mail_previews edit edit_recipients update_recipients
        update_status update destroy force_start force_step_up refresh_stats
      ]
    before_action :set_excluded_communes, only: %i[show update_status]
    before_action :redirect_planned_campaign, only: %i[edit_recipients]
    # rubocop:enable Rails/LexicallyScopedActionFilter

    def index
      @ransack = Campaign.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @campaigns = pagy(@ransack.result, items: 20)
    end

    def new
      @campaign = Campaign.new
    end

    def force_start
      raise unless @campaign.can_force_start?

      @campaign.update_columns(date_lancement: Time.zone.today, status: "planned")
      enqueue_campaign_jobs
      redirect_to admin_campaign_path(@campaign), notice: "La campagne est en train de démarrer…"
    end

    def force_step_up
      raise unless @campaign.can_force_step_up?

      @campaign.update_columns("date_#{@campaign.next_step}": Time.zone.today)
      enqueue_campaign_jobs
      redirect_to admin_campaign_path(@campaign),
                  notice: "La campagne est en train de passer à l'étape #{@campaign.next_step}…"
    end

    def refresh_stats
      Campaigns::RefreshCampaignStatsJob.perform_async(@campaign.id)
      redirect_to(
        admin_campaign_path(@campaign),
        notice: "Les statistiques sont en train d'être rafraîchies…"
      )
    end

    private

    def authorize_campaign = true

    def routes_prefix = :admin

    def enqueue_campaign_jobs
      Campaigns::CronJob.perform_inline
      Campaigns::RefreshCampaignStatsJob.perform_in(10.minutes, @campaign.id)
    end

    def search_params
      return {} if params[:campaign_search].blank?

      params.require(:campaign_search).permit(:departement_code, :status).to_h.symbolize_keys
    end

    def after_destroy_path = admin_campaigns_path
    def active_nav_links = %w[Campagnes]
  end
end

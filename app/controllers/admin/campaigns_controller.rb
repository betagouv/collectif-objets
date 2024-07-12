# frozen_string_literal: true

module Admin
  class CampaignsController < BaseController
    include CampaignsControllerConcern

    def index
      @ransack = Campaign.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @campaigns = pagy(@ransack.result, items: 20)
    end

    def new
      @campaign = Campaign.new
    end

    def force_start
      set_campaign
      raise unless @campaign.can_force_start?

      update_dates_up_to "date_lancement"
      @campaign.update_columns status: "planned"
      enqueue_campaign_jobs
      redirect_to admin_campaign_path(@campaign), notice: "La campagne est en train de démarrer…"
    end

    def force_step_up
      set_campaign
      raise unless @campaign.can_force_step_up?

      next_step = @campaign.next_step
      update_dates_up_to("date_#{next_step}")
      enqueue_campaign_jobs
      redirect_to admin_campaign_path(@campaign), notice: "La campagne est en train de passer à l'étape #{next_step}…"
    end

    private

    def enqueue_campaign_jobs
      Campaigns::CronJob.perform_now
      Campaigns::RefreshCampaignStatsJob.set(wait: 10.minutes).perform_later(@campaign.id)
    end

    def search_params
      return {} if params[:campaign_search].blank?

      params.require(:campaign_search).permit(:departement_code, :status).to_h.symbolize_keys
    end

    def update_dates_up_to(up_to_date_field)
      dates_attributes =
        Campaign::DATE_FIELDS[0..Campaign::DATE_FIELDS.index(up_to_date_field)]
          .each_with_index.to_h do |date_field, index|
          weeks_ago = 5 - index
          date = (Time.zone.today - weeks_ago.weeks).monday
          [date_field, date]
        end
      @campaign.update_columns dates_attributes
    end

    def authorize_campaign = true
    def routes_prefix = :admin
    def after_destroy_path = admin_campaigns_path
    def active_nav_links = %w[Campagnes]
  end
end

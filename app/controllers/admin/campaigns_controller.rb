# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module Admin
  class CampaignsController < BaseController
    before_action(
      :set_campaign, only: %i[
        show show_statistics mail_previews edit edit_recipients update_recipients
        update_status update destroy force_start force_step_up
        refresh_stats refresh_delivery_infos
      ]
    )
    before_action :set_excluded_communes, only: %i[show update_status]

    def index
      @ransack = Campaign.ransack(params[:q])
      @query_present = params[:q].present?
      @pagy, @campaigns = pagy(@ransack.result, items: 20)
    end

    def show; end

    def show_statistics; end

    def edit_recipients
      return if @campaign.draft?

      redirect_to(
        admin_campaign_path(@campaign),
        alert: "Impossible de modifier les communes destinataires de cette campagne car elle n'est plus en brouillon"
      )
    end

    def new
      @campaign = Campaign.new
    end

    def edit; end

    def create
      @campaign = Campaign.new(**campaign_params)
      if @campaign.save
        redirect_to(
          admin_campaign_path(@campaign),
          notice: "La campagne a été créée avec succès, elle peut être configurée"
        )
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @campaign.update(campaign_params)
        redirect_to admin_campaign_path(@campaign), notice: "La campagne a été modifiée"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def update_recipients
      @campaign.commune_ids = params.fetch(:campaign, {}).fetch(:recipients_attributes, []).pluck(:commune_id)
      redirect_to admin_campaign_path(@campaign), notice: "Les destinataires de la campagne ont été modifiés"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to(
        admin_campaign_edit_recipients_path(@campaign),
        alert: "#{e.record.commune.nom} : #{e.record.errors.first.message}"
      )
    end

    def update_status
      status_event = params.require(:campaign).require(:status_event)
      success = transit_campaign!(status_event)
      return redirect_to admin_campaign_path(@campaign), notice: "La campagne a été modifiée" if success

      error = if status_event == "plan" && !@campaign.only_inactive_communes?
                "cannot_plan_active_communes"
              else
                "cannot_transit"
              end
      @campaign.errors.add(:base, t("activerecord.errors.models.campaign.aasm.#{error}"))
      render :show, status: :unprocessable_entity
    end

    def destroy
      if @campaign.destroy
        redirect_to admin_campaigns_path, status: :see_other, notice: "Le brouillon de campagne a été détruit"
      else
        @campaign.errors.add(:base, "Impossible de supprimer ce brouillon de campagne")
        render :show, status: :unprocessable_entity
      end
    end

    def mail_previews
      @count = params.fetch(:count, "10").to_i
      raise "invalid count" if @count.nil? || @count.negative?
      raise "cannot generate more than 100 mails" if @count > 100
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

    def refresh_delivery_infos
      Campaigns::RefreshCampaignStatsJob.perform_in(10.minutes, @campaign.id)
      redirect_to(
        admin_campaign_path(@campaign),
        notice: "Les informations d'envoi des mails sont en train d'être rafraîchies…"
      )
    end

    def refresh_stats
      Campaigns::RefreshCampaignStatsJob.perform_async(@campaign.id)
      redirect_to(
        admin_campaign_path(@campaign),
        notice: "Les statistiques sont en train d'être rafraîchies…"
      )
    end

    private

    def set_campaign
      @campaign = Campaign.find(params[:campaign_id] || params[:id])
    end

    def set_excluded_communes
      @excluded_communes = (@campaign.departement.communes - @campaign.communes).sort_by(&:nom)
    end

    def campaign_params
      params.require(:campaign)
        .permit(
          :departement_code, :date_lancement, :date_relance1,
          :date_relance2, :date_relance3, :date_fin,
          :sender_name, :signature, :nom_drac
        )
    end

    def transit_campaign!(status_event)
      can_transition = @campaign.aasm.permitted_transitions.pluck(:event).include?(status_event.to_sym)
      can_transition && @campaign.send("#{status_event}!")
    end

    def enqueue_campaign_jobs
      Campaigns::CronJob.perform_inline
      Campaigns::RefreshCampaignStatsJob.perform_in(10.minutes, @campaign.id)
    end

    def search_params
      return {} if params[:campaign_search].blank?

      params.require(:campaign_search).permit(:departement_code, :status).to_h.symbolize_keys
    end
  end
end
# rubocop:enable Metrics/ClassLength

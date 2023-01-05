# frozen_string_literal: true

module CampaignsControllerConcern
  include ActiveSupport::Concern

  def show; end

  def edit_recipients; end

  def edit; end

  def create
    @campaign = Campaign.new(**campaign_params)
    @departement = @campaign.departement
    authorize_campaign
    if @campaign.save
      redirect_to send("#{routes_prefix}_campaign_path", @campaign),
                  notice: "La campagne a été créée avec succès, elle peut être configurée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      redirect_to send("#{routes_prefix}_campaign_path", @campaign), notice: "La campagne a été modifiée"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_recipients
    @campaign.commune_ids = params_recipient_commune_ids
    redirect_to send("#{routes_prefix}_campaign_path", @campaign),
                notice: "Les destinataires de la campagne ont été modifiés"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to \
      send("#{routes_prefix}_campaign_edit_recipients_path", @campaign),
      alert: "#{e.record.commune.nom} : #{e.record.errors.first.message}"
  end

  def update_status
    status_event = params.require(:campaign).require(:status_event)
    if @campaign.update_status(status_event)
      redirect_to send("#{routes_prefix}_campaign_path", @campaign), notice: "La campagne a été modifiée"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    if @campaign.destroy
      redirect_to after_destroy_path, status: :see_other, notice: "Le brouillon de campagne a été détruit"
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

  private

  def params_recipient_commune_ids
    params.fetch(:campaign, {}).fetch(:recipients_attributes, []).pluck(:commune_id)
  end

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

  def redirect_planned_campaign
    return if @campaign.draft?

    redirect_to(
      [routes_prefix, @campaign],
      alert: "Impossible de modifier les communes destinataires de cette campagne car elle n'est plus en brouillon"
    )
  end
end

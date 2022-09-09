# frozen_string_literal: true

class CampaignRecipientsController < ApplicationController
  before_action :restrict_access, :set_instance_vars
  before_action :validate_mail_preview_params, only: [:mail_preview]

  def show; end

  def update
    if @recipient.update(recipient_params)
      redirect_to campaign_recipient_path(@recipient.campaign, @recipient), notice: "Destinataire mis à jour"
    else
      render :show, status: :unprocessable_entity
    end
  end

  def mail_preview
    mail = CampaignV1Mailer
      .with(user: @user, commune: @commune, campaign: @campaign)
      .send("#{mail_name}_email")
    render(
      partial: "mail_preview",
      locals: { campaign: @campaign, recipient: @recipient, step: params[:step], variant: params[:variant], mail: }
    )
  end

  private

  def recipient_params
    params.require(:campaign_recipient)
      .permit(:opt_out, :opt_out_reason)
      .merge(params[:campaign_recipient][:opt_out] == "0" ? { opt_out_reason: nil } : {})
  end

  def set_instance_vars
    @recipient = CampaignRecipient.includes(:campaign, :commune).find(params[:id] || params[:recipient_id])
    @commune = @recipient.commune
    @campaign = @recipient.campaign
    @user = @commune.users.first
  end

  def restrict_access
    return true if current_admin_user.present?

    redirect_to root_path, alert: "La gestion de campagne est réservée aux administrateurs"
  end

  def validate_mail_preview_params
    raise ActionController::UnpermittedParameters, %w[step] unless Campaign::STEPS.include?(params[:step])

    raise ActionController::UnpermittedParameters, %w[variant] \
      unless Co::Campaigns::Mail::VARIANTS.include?(params[:variant])

    raise StandardError, "mail #{mail_name} does not exist" unless CampaignV1Mailer::MAIL_NAMES.include?(mail_name)
  end

  def mail_name
    [params[:step], params[:variant]].join("_")
  end
end

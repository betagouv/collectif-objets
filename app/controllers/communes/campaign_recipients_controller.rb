# frozen_string_literal: true

module Communes
  class CampaignRecipientsController < BaseController
    before_action :set_recipient

    def update
      if @recipient.update(recipient_params)
        redirect_to edit_user_registration_path, notice: "Vos préférences de communication ont été mises à jour"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def recipient_params
      params.require(:campaign_recipient)
        .permit(:opt_out, :opt_out_reason)
        .merge(params[:campaign_recipient][:opt_out] == "0" ? { opt_out_reason: nil } : {})
    end

    def set_recipient
      @recipient = CampaignRecipient.includes(:campaign, :commune).find(params[:id])
      authorize(@recipient)
    end
  end
end

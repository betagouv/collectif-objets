# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :check_authorized

  def chatwoot
    ReceiveChatwootWebhookJob.perform_async(chatwoot_params.to_hash)
    head :no_content
  end

  protected

  def check_authorized
    return true if
      request.ip == "148.253.96.190" && # scalingo outgoing IP for osc-secnum-fr1
      params[:secret_key] == Rails.application.credentials.chatwoot&.webhooks_secret_key

    render plain: "unauthorized", status: :unauthorized
  end

  def chatwoot_params
    params.permit(:event, :message_type, :content, account: [:id], sender: [:name], conversation: [:id])
  end
end

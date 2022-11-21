# frozen_string_literal: true

module Admin
  class CampaignEmailsController < BaseController
    before_action :set_instance_vars

    def redirect_to_sib_preview
      raise if @email.sib_message_id.blank?

      sib_uuid = Co::SendInBlueClient.instance.get_transactional_email_uuid(message_id: @email.sib_message_id)
      raise if sib_uuid.blank?

      redirect_to "https://app-smtp.sendinblue.com/log/preview/#{sib_uuid}", allow_other_host: true
    end

    private

    def set_instance_vars
      @email = CampaignEmail.find(params[:email_id])
      @campaign = @email.campaign
    end
  end
end

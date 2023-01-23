# frozen_string_literal: true

module EmailAttachmentsControllerConcern
  extend ActiveSupport::Concern
  included do
    before_action :set_message, :authorize_message, :set_email_attachment
  end

  def show
    Co::SendInBlueClient.instance.download_inbound_attachment(@email_attachment.download_token) do |f|
      send_file(f, filename: @email_attachment.filename, type: @email_attachment.content_type)
    end
  end

  private

  def set_message
    @message = Message.find params[:message_id]
  end

  def authorize_message = authorize(@message)

  def set_email_attachment
    @email_attachment = @message.attachments[params[:id].to_i]
  end
end

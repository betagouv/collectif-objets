# frozen_string_literal: true

module Communes
  class MessagesController < BaseController
    before_action :set_messages, only: :index

    def index
      @new_message = Message.new(commune: @commune)
    end

    def create
      @message = Message.new(message_params)
      authorize @message
      return render_index_after_create_error unless @message.save

      @message.enqueue_message_received_emails
      respond_to do |format|
        format.html { redirect_to commune_messages_path(@commune) }
        format.turbo_stream
      end
    end

    def download_skipped_attachment
      message = Message.find(params[:message_id])
      authorize(message, :show?)
      inbound_email_attachment = message.skipped_attachments[params[:attachment_index].to_i]
      Co::SendInBlueClient.instance.download_inbound_attachment(inbound_email_attachment.download_token) do |f|
        send_file(f, filename: inbound_email_attachment.filename, type: inbound_email_attachment.content_type)
      end
    end

    protected

    def set_messages
      @messages = policy_scope(Message)
        .includes(:author, :files_attachments, :files_blobs)
        .where(commune: @commune)
        .order(created_at: :asc)
    end

    def message_params
      params.require(:message).permit(:text, files: [])
        .merge(origin: "web", commune_id: @commune.id, author: current_user)
    end

    def render_index_after_create_error
      set_messages
      @new_message = @message
      render :index, status: :unprocessable_entity
    end
  end
end

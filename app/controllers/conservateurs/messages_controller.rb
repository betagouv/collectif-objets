# frozen_string_literal: true

module Conservateurs
  class MessagesController < BaseController
    before_action :set_commune
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
        format.html { redirect_to conservateurs_commune_messages_path(@commune) }
        format.turbo_stream
      end
    end

    protected

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def set_messages
      @messages = policy_scope(Message)
        .includes(:author, :files_attachments, :files_blobs)
        .where(commune: @commune)
        .order(created_at: :asc)
    end

    def render_index_after_create_error
      set_messages
      @new_message = @message
      render :index, status: :unprocessable_entity
    end

    def message_params
      params.require(:message).permit(:text, files: [])
        .merge(origin: "web", commune_id: @commune.id, author: current_conservateur)
    end
  end
end

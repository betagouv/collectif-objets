# frozen_string_literal: true

module Admin
  class MessagesController < BaseController
    before_action :set_commune

    def create
      @message = Message.new(**message_params)
      redirect_to admin_commune_path(@commune), alert: "impossible d'envoyer le message" unless @message.save

      @message.enqueue_message_received_emails
      respond_to do |format|
        format.html { redirect_to admin_commune_path(@commune), notice: "message envoyé" }
        format.turbo_stream
      end
    end

    private

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def message_params
      params.require(:message).permit(:text, files: [])
        .merge(origin: "web", commune_id: @commune.id, author: current_admin_user)
    end

    def active_nav_links = %w[Communes]
  end
end

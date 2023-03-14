# frozen_string_literal: true

module Conservateurs
  class MessagesController < BaseController
    before_action :set_commune
    before_action :set_dossier
    before_action :set_messages, only: :index # rubocop:disable Rails/LexicallyScopedActionFilter
    include MessagesControllerConcern

    protected

    def after_create_path = conservateurs_commune_messages_path(@commune)

    def new_message_author = current_conservateur

    def set_commune
      @commune = Commune.find(params[:commune_id])
    end

    def set_dossier
      @dossier = @commune.dossier
    end

    def set_messages
      @messages = policy_scope(Message)
                    .includes(:author, :files_attachments, :files_blobs)
                    .where(commune: @commune)
                    .order(created_at: :asc)
    end
  end
end

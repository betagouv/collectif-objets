# frozen_string_literal: true

module Communes
  class MessagesController < BaseController
    before_action :set_messages, only: :index # rubocop:disable Rails/LexicallyScopedActionFilter
    include MessagesControllerConcern

    protected

    def after_create_path = commune_messages_path(@commune)

    def new_message_author = current_user

    def set_messages
      @messages = policy_scope(Message)
                    .includes(:author, :files_attachments, :files_blobs)
                    .where(commune: @commune)
                    .order(created_at: :asc)
    end
  end
end

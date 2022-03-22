# frozen_string_literal: true

class ReceiveChatwootWebhookJob
  include Sidekiq::Job

  def perform(data)
    return if data["event"] != "message_created" ||
              data["message_type"] != "incoming"

    @data = data
    SendMattermostNotificationJob.perform_inline("chatwoot_message", payload)
  end

  protected

  def url
    "https://collectif-objets-chatwoot.osc-secnum-fr1.scalingo.io" \
      "/app/accounts/#{@data['account']['id']}" \
      "/conversations/#{@data['conversation']['id']}"
  end

  def payload
    {
      "sender_email" => @data["sender"]["name"],
      "content" => @data["content"],
      "url" => url
    }
  end
end

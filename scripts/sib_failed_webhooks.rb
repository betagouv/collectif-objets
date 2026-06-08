# frozen_string_literal: true

client = Co::SendInBlueClient.instance

client.list_inbound_events
  .select { it["recipient"].ends_with?("reponse.collectifobjets.org") }
  .map { client.get_inbound_event(it["uuid"]) }
  .select { it["logs"].last["type"] == "webhookFailed" }
  .each { puts it }

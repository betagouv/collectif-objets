# frozen_string_literal: true

client = Co::SendInBlueClient.instance

client.list_inbound_events
  .select { _1["recipient"].ends_with?("reponse.collectifobjets.org") }
  .map { client.get_inbound_event(_1["uuid"]) }
  .select { _1["logs"].last["type"] == "webhookFailed" }
  .each { puts _1 }

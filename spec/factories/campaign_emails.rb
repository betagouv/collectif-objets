# frozen_string_literal: true

FactoryBot.define do
  factory :campaign_email do
    association :recipient, factory: :campaign_recipient
    step { "lancement" }
    sib_message_id { "some-id" }
    sent { nil }
    delivered { nil }
    opened { nil }
    clicked { nil }
    error { nil }
    error_reason { nil }
  end
end

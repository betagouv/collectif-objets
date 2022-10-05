# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

RSpec.describe Campaigns::SynchronizeEmailJob, type: :job do
  describe "#perform" do
    subject { Campaigns::SynchronizeEmailJob.perform_inline(campaign_email.id) }

    let!(:campaign_email) { create(:campaign_email, sib_message_id: "some-id-thing") }

    before do
      expect(Co::SendInBlueClient.instance).to receive(:get_transaction_email_events)
        .with("some-id-thing")
        .and_return(events)
    end

    context "no events" do
      let(:events) { [] }
      it "should reset everything" do
        subject
        campaign_email.reload
        expect(campaign_email.sent).to eq false
        expect(campaign_email.delivered).to eq false
        expect(campaign_email.opened).to eq false
        expect(campaign_email.clicked).to eq false
        expect(campaign_email.error).to be_nil
        expect(campaign_email.error_reason).to be_nil
        expect(campaign_email.last_sib_synchronization_at).to be_within(2.seconds).of(Time.zone.now)
        expect(campaign_email.sib_events).to be_empty
      end
    end

    context "delivered" do
      let(:events) do
        [
          { event: "requests", date: Date.new(2022, 8, 1) + 10.hours },
          { event: "delivered", date: Date.new(2022, 8, 1) + 11.hours }
        ].map { Co::SendInBlueClient::EVENT_STRUCT.new(_1[:event], _1[:date]) }
      end

      it "should store everything" do
        subject
        campaign_email.reload
        expect(campaign_email.sent).to eq true
        expect(campaign_email.delivered).to eq true
        expect(campaign_email.opened).to eq false
        expect(campaign_email.clicked).to eq false
        expect(campaign_email.error).to be_nil
        expect(campaign_email.error_reason).to be_nil
        expect(campaign_email.last_sib_synchronization_at).to be_within(2.seconds).of(Time.zone.now)
        expect(campaign_email.sib_events.count).to eq(2)
      end
    end

    context "clicked" do
      let(:events) do
        [
          { event: "requests", date: Date.new(2022, 8, 1) + 10.hours },
          { event: "delivered", date: Date.new(2022, 8, 1) + 11.hours },
          { event: "opened", date: Date.new(2022, 8, 1) + 12.hours },
          { event: "clicks", date: Date.new(2022, 8, 1) + 13.hours }
        ].map { Co::SendInBlueClient::EVENT_STRUCT.new(_1[:event], _1[:date]) }
      end

      it "should store everything" do
        subject
        campaign_email.reload
        expect(campaign_email.sent).to eq true
        expect(campaign_email.delivered).to eq true
        expect(campaign_email.opened).to eq true
        expect(campaign_email.clicked).to eq true
        expect(campaign_email.error).to be_nil
        expect(campaign_email.error_reason).to be_nil
        expect(campaign_email.last_sib_synchronization_at).to be_within(2.seconds).of(Time.zone.now)
        expect(campaign_email.sib_events.count).to eq(4)
      end
    end

    context "opened but not sent nor delivered (!)" do
      let(:events) do
        [
          { event: "opened", date: Date.new(2022, 8, 1) + 12.hours },
          { event: "clicks", date: Date.new(2022, 8, 1) + 13.hours }
        ].map { Co::SendInBlueClient::EVENT_STRUCT.new(_1[:event], _1[:date]) }
      end

      it "should mark it as sent and delivered anyhow" do
        subject
        campaign_email.reload
        expect(campaign_email.sent).to eq true
        expect(campaign_email.delivered).to eq true
        expect(campaign_email.opened).to eq true
        expect(campaign_email.clicked).to eq true
        expect(campaign_email.error).to be_nil
        expect(campaign_email.sib_events.count).to eq(2)
      end
    end

    context "soft bounce error" do
      let(:events) do
        [
          Co::SendInBlueClient::EVENT_STRUCT.new("requests", Date.new(2022, 8, 1) + 10.hours),
          Co::SendInBlueClient::EVENT_STRUCT.new(
            "error",
            Date.new(2022, 8, 1) + 11.hours,
            "soft_bounces",
            "Mail MX thing not working"
          )
        ]
      end

      it "should store everything" do
        subject
        campaign_email.reload
        expect(campaign_email.sent).to eq true
        expect(campaign_email.delivered).to eq false
        expect(campaign_email.opened).to eq false
        expect(campaign_email.clicked).to eq false
        expect(campaign_email.error).to eq "soft_bounces"
        expect(campaign_email.error_reason).to eq("Mail MX thing not working")
        expect(campaign_email.last_sib_synchronization_at).to be_within(2.seconds).of(Time.zone.now)
        expect(campaign_email.sib_events.count).to eq(2)
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength

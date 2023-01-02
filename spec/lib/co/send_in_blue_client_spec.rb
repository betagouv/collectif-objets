# frozen_string_literal: true

require "rails_helper"

RSpec.describe Co::SendInBlueClient do
  let(:client) { Co::SendInBlueClient.instance }

  describe "#get_transaction_email_events" do
    let(:subject) { client.get_transaction_email_events(message_id) }

    before do
      expect(client).to receive(:get_api_request_raw).and_return(response_body)
    end

    context "delivered" do
      let(:response_body) do
        <<~JSON.strip
          {
            "events": [
              {
                "email": "adrien@dipasquale.fr",
                "date": "2022-08-23T11:26:10.623+02:00",
                "subject": "Envoi 1661246768 d'un dossier Collectif Objets",
                "messageId": "<63049d3042a81_3d3b1ae08868@Adriens-Air.mail>",
                "event": "delivered",
                "tag": "",
                "ip": "212.146.222.15",
                "from": "collectifobjets@beta.gouv.fr"
              },
              {
                "email": "adrien@dipasquale.fr",
                "date": "2022-08-23T11:26:09.939+02:00",
                "subject": "Envoi 1661246768 d'un dossier Collectif Objets",
                "messageId": "<63049d3042a81_3d3b1ae08868@Adriens-Air.mail>",
                "event": "requests",
                "tag": "",
                "ip": "212.146.222.15",
                "from": "collectifobjets@beta.gouv.fr"
              }
            ]
          }
        JSON
      end

      let(:message_id) { "<63049d3042a81_3d3b1ae08868@Adriens-Air.mail>" }

      it "should return parsed events" do
        res = subject
        expect(res.count).to eq(2)
        expect(res[0].event).to eq("requests")
        expect(res[0].date).to be_within(1.day).of(Date.new(2022, 8, 23))
        expect(res[1].event).to eq("delivered")
        expect(res[1].date).to be_within(1.day).of(Date.new(2022, 8, 23))
      end

      context "message_id mismatch" do
        let(:message_id) { "whatever" }
        it { should be_empty }
      end
    end

    context "soft bounce" do
      let(:response_body) do
        <<~JSON.strip
          {
            "events": [
              {
                "email": "wazaa@lol.fr",
                "date": "2022-08-23T11:31:52.104+02:00",
                "subject": "Envoi 1661247107 d'un dossier Collectif Objets",
                "messageId": "<63049e8436394_3e901ae0778d8@Adriens-Air.mail>",
                "event": "softBounces",
                "reason": "Unable to find MX of domain lol.fr",
                "tag": "",
                "ip": "212.146.222.15",
                "from": "collectifobjets@beta.gouv.fr"
              },
              {
                "email": "wazaa@lol.fr",
                "date": "2022-08-23T11:31:51.360+02:00",
                "subject": "Envoi 1661247107 d'un dossier Collectif Objets",
                "messageId": "<63049e8436394_3e901ae0778d8@Adriens-Air.mail>",
                "event": "requests",
                "tag": "",
                "ip": "212.146.222.15",
                "from": "collectifobjets@beta.gouv.fr"
              }
            ]
          }
        JSON
      end

      let(:message_id) { "<63049e8436394_3e901ae0778d8@Adriens-Air.mail>" }

      it "should return parsed error" do
        res = subject
        expect(res.count).to eq(2)
        expect(res[0].event).to eq("requests")
        expect(res[0].date).to be_within(1.day).of(Date.new(2022, 8, 23))
        expect(res[1].event).to eq("error")
        expect(res[1].date).to be_within(1.day).of(Date.new(2022, 8, 23))
        expect(res[1].error).to eq("soft_bounces")
        expect(res[1].error_reason).to eq("Unable to find MX of domain lol.fr")
      end
    end
  end
end

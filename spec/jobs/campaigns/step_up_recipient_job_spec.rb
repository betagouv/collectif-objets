# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

RSpec.describe Campaigns::StepUpRecipientJob, type: :job do
  describe "#perform" do
    let!(:commune) { create(:commune, status: "inactive") }
    let!(:campaign) { create(:campaign) }

    subject { Campaigns::StepUpRecipientJob.new.perform(recipient.id, "rappel1") }

    before do
      expect(CampaignRecipient).to receive_message_chain(:includes, :find)
        .with(any_args)
        .with(recipient.id)
        .and_return(recipient)
    end

    context "the recipient has opted out" do
      let!(:user) { create(:user, commune:) }
      let!(:recipient) do
        create(:campaign_recipient, campaign:, commune:, current_step: "lancement", opt_out: true,
                                    opt_out_reason: "other")
      end

      it "should not do anything" do
        expect(CampaignV1Mailer).not_to receive(:with)
        res = subject
        expect(recipient.current_step).to eq("lancement") # should not change
        expect(res).to eq false
      end
    end

    context "safeguard : reminder for active communes are never sent" do
      let!(:commune) { create(:commune, status: :started) }
      let!(:user) { create(:user, commune:) }
      let!(:recipient) do
        create(:campaign_recipient, campaign:, commune:, current_step: "lancement")
      end

      it "should not do anything" do
        expect(CampaignV1Mailer).not_to receive(:with)
        res = subject
        expect(recipient.current_step).to eq("lancement") # should not change
        expect(res).to eq false
      end
    end

    context "the commune step does not match campaign previous step" do
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "rappel1") }
      let!(:user) { create(:user, commune:) }

      it "should not do anything" do
        expect(CampaignV1Mailer).not_to receive(:with)
        res = subject
        expect(recipient.current_step).to eq("rappel1") # should not change
        expect(res).to eq false
      end
    end

    context "it calls the mailer" do
      let!(:user) { create(:user, commune:, email: "mairie-bleue@france.fr") }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }

      before do
        message_delivery_double = instance_double(ActionMailer::MessageDelivery)
        expect(CampaignV1Mailer).to receive_message_chain(:with, :rappel1_email)
          .with(user:, commune:, campaign:)
          .with(no_args)
          .and_return(message_delivery_double)
        smtp_response_double = instance_double(Net::SMTP::Response, string: smtp_response_text)
        expect(message_delivery_double).to receive(:deliver_now!).and_return(smtp_response_double)
        mail_message_double = instance_double(Mail::Message)
        allow(message_delivery_double).to receive(:message).and_return(mail_message_double)
        mail_body_double = instance_double(Mail::Body)
        allow(mail_message_double).to receive(:body).and_return(mail_body_double)
        allow(mail_body_double).to receive(:raw_source).and_return("<html>long text</html>")
        allow(mail_message_double).to receive(:header).and_return(
          [instance_double(Mail::Field, name: "To", value: "mairie-bleue@france.fr")]
        )
        allow(mail_message_double).to receive(:subject).and_return("Thoiry, venez recenser !")
      end

      context "correct SMTP response" do
        let(:smtp_response_text) { "250 Message queued as <2123@some-host>" }

        it "should send a mail and update the recipient" do
          expect(recipient.emails.count).to eq(0)
          res = subject
          expect(res).to eq true
          recipient.reload
          expect(recipient.current_step).to eq("rappel1")
          expect(recipient.emails.count).to eq(1)
          email = recipient.emails.first
          expect(email.step).to eq("rappel1")
          expect(email.sib_message_id).to eq("<2123@some-host>")
          expect(email.headers["To"]).to eq("mairie-bleue@france.fr")
          expect(email.raw_html).to eq("<html>long text</html>")
          expect(email.subject).to eq("Thoiry, venez recenser !")
        end
      end

      context "SMTP answers weirdly" do
        let(:smtp_response_text) { "509 Error SMTP weird" }
        it "should raise without updating the recipient" do
          expect { subject }.to raise_exception(/Unexpected SMTP response/)
          expect(recipient.reload.current_step).to eq("lancement")
        end
      end
    end

    context "there is no user at all" do
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }

      it "should not send a mail and update the recipient" do
        expect(CampaignV1Mailer).not_to receive(:with)
        expect { subject }.to raise_exception(/Missing user/)
        expect(recipient.reload.current_step).to eq("lancement")
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength

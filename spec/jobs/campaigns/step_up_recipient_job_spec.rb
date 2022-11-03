# frozen_string_literal: true

require "rails_helper"

RSpec.describe Campaigns::StepUpRecipientJob, type: :job do
  describe "#perform" do
    let!(:campaign) { create(:campaign) }
    let(:campaign_mail_double) do
      instance_double(
        Co::Campaigns::Mail,
        subject: "Thoiry, venez recenser !",
        headers: { "To" => "mairie-bleue@france.fr" },
        raw_html: "<html>long text</html>",
        step: "relance1",
        email_name:
      )
    end

    subject { Campaigns::StepUpRecipientJob.new.perform(recipient.id, to_step) }

    before do
      expect(CampaignRecipient).to receive_message_chain(:includes, :find)
        .with(any_args)
        .with(recipient.id)
        .and_return(recipient)
      allow(recipient).to receive(:should_skip_mail_for_step)
        .with(to_step).and_return(should_skip_mail)
      allow(Co::Campaigns::Mail).to receive(:new).and_return(campaign_mail_double)
    end

    context "the recipient has opted out" do
      let(:email_name) { "relance1_inactive_email" }
      let!(:commune) { create(:commune_with_user, status: "inactive") }
      let(:to_step) { "relance1" }
      let!(:user) { create(:user, commune:) }
      let!(:recipient) do
        create(
          :campaign_recipient,
          campaign:, commune:, current_step: "lancement", opt_out: true, opt_out_reason: "other"
        )
      end
      let(:should_skip_mail) { false }

      it "should not do anything" do
        expect(campaign_mail_double).not_to receive(:deliver_now!)
        res = subject
        expect(recipient.current_step).to eq("lancement") # should not change
        expect(res).to eq false
      end
    end

    context "safeguard : never step up for completed communes" do
      let(:email_name) { "relance1_inactive_email" }
      let(:to_step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "completed") }
      let!(:user) { create(:user, commune:) }
      let!(:recipient) do
        create(:campaign_recipient, campaign:, commune:, current_step: "lancement")
      end
      let(:should_skip_mail) { false }

      it "should not do anything" do
        expect(campaign_mail_double).not_to receive(:deliver_now!)
        res = subject
        expect(recipient.current_step).to eq("lancement") # should not change
        expect(res).to eq false
      end
    end

    context "the commune step does not match previous step" do
      let(:email_name) { "relance1_inactive_email" }
      let(:to_step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "inactive") }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "relance1") }
      let!(:user) { create(:user, commune:) }
      let(:should_skip_mail) { false }

      it "should not do anything" do
        expect(campaign_mail_double).not_to receive(:deliver_now!)
        res = subject
        expect(recipient.current_step).to eq("relance1") # should not change
        expect(res).to eq false
      end
    end

    context "it tries sending an email" do
      let(:email_name) { "relance1_inactive_email" }
      let(:to_step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "inactive") }
      let!(:user) { create(:user, commune:, email: "mairie-bleue@france.fr") }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }
      let(:should_skip_mail) { false }

      before do
        smtp_response_double = instance_double(Net::SMTP::Response, string: smtp_response_text)
        expect(campaign_mail_double).to receive(:deliver_now!).and_return(smtp_response_double)
      end

      context "correct SMTP response" do
        let(:smtp_response_text) { "250 Message queued as <2123@some-host>" }

        it "should send a mail and update the recipient" do
          expect(recipient.emails.count).to eq(0)
          res = subject
          expect(res).to eq true
          recipient.reload
          expect(recipient.current_step).to eq("relance1")
          expect(recipient.emails.count).to eq(1)
          email = recipient.emails.first
          expect(email.step).to eq("relance1")
          expect(email.sib_message_id).to eq("<2123@some-host>")
          expect(email.headers["To"]).to eq("mairie-bleue@france.fr")
          expect(email.subject).to eq("Thoiry, venez recenser !")
          expect(email.email_name).to eq("relance1_inactive_email")
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

    context "mail ne doit pas être envoyé" do
      let(:email_name) { "relance1_started_email" }
      let(:to_step) { "relance1" }
      let!(:commune) { create(:commune_with_user, status: "started") }
      let!(:user) { create(:user, commune:, email: "mairie-bleue@france.fr") }
      let!(:recipient) { create(:campaign_recipient, campaign:, commune:, current_step: "lancement") }
      let(:should_skip_mail) { true }

      it "should step up recipient without sending an email" do
        expect(campaign_mail_double).not_to receive(:deliver_now!)
        res = subject
        expect(res).to eq true
        expect(recipient.current_step).to eq("relance1")
        expect(recipient.emails).to be_empty
      end
    end

    context "there is no user at all" do
      let(:email_name) { "relance1_inactive_email" }
      let(:to_step) { "relance1" }
      let!(:commune) { create(:commune, status: "inactive") }
      let!(:recipient) do
        build(:campaign_recipient, campaign:, commune:, current_step: "lancement")
          .tap { _1.save(validate: false) }
      end
      let(:should_skip_mail) { false }

      it "should not send a mail and update the recipient" do
        expect(campaign_mail_double).not_to receive(:deliver_now!)
        expect { subject }.to raise_exception(/Missing user/)
        expect(recipient.reload.current_step).to eq("lancement")
      end
    end
  end
end

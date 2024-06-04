# frozen_string_literal: true

require "rails_helper"

RSpec.describe Co::Campaigns::Mail do
  let(:mail) { Co::Campaigns::Mail.new(user:, commune:, campaign:, step:) }

  let!(:user) { create(:user, commune:) }
  let!(:campaign) { create(:campaign) }

  describe "email_name" do
    subject { mail.email_name }

    context "lancement" do
      let(:step) { "lancement" }
      let!(:commune) { create(:commune, status: "inactive") }
      it { should eq "lancement_email" }
    end

    context "relance1 inactive" do
      let(:step) { "relance1" }
      let!(:commune) { create(:commune, status: "inactive") }
      it { should eq "relance1_inactive_email" }
    end

    context "relance1 started with all recensements" do
      let(:step) { "relance1" }
      let!(:commune) { create(:commune_en_cours_de_recensement) }
      let!(:recensement1) { create(:recensement, objet: create(:objet, commune:), dossier: commune.dossier) }
      let!(:recensement2) { create(:recensement, objet: create(:objet, commune:), dossier: commune.dossier) }
      it { should eq "relance1_to_complete_email" }
    end

    context "relance1 started with some recensements" do
      let(:step) { "relance1" }
      let!(:commune) { create(:commune, status: "started") }
      let!(:recensement1) { create(:recensement, objet: create(:objet, commune:)) }
      let!(:objet2) { create(:objet, commune:) }
      it { should eq "relance1_started_email" }
    end
  end

  describe "email, headers and raw_html" do
    let!(:commune) { create(:commune, status: "inactive") }
    let(:step) { "lancement" }

    let(:message_delivery_double) { instance_double(ActionMailer::MessageDelivery) }

    before do
      expect(CampaignV1Mailer).to receive_message_chain(:with, :lancement_email)
        .with(user:, commune:, campaign:)
        .with(no_args)
        .and_return(message_delivery_double)
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

    describe "email" do
      it "should return the email" do
        expect(mail.email).to eq(message_delivery_double)
      end
    end

    it "should return raw_html" do
      expect(mail.raw_html).to eq("<html>long text</html>")
    end

    it "should return headers" do
      expect(mail.headers).to eq({ "To" => "mairie-bleue@france.fr" })
    end

    it "should return subject" do
      expect(mail.subject).to eq("Thoiry, venez recenser !")
    end
  end
end

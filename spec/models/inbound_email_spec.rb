# frozen_string_literal: true

require "rails_helper"

RSpec.describe InboundEmail, type: :model do
  describe "validate recipient email is support" do
    let(:inbound_email) { InboundEmail.from_raw({ "To" => [{ "Address" => to_email }] }) }
    before { inbound_email.validate }
    subject { !inbound_email.errors.key?(:to_email) }

    context "valid email " do
      let(:to_email) { "mairie-12304-12987asdce12987asdce@reply-loophole.collectifobjets.org" }
      it { should eq true }
    end

    context "random email" do
      let(:to_email) { "nimporte@qui.quoi" }
      it { should eq false }
    end

    context "invalid domain" do
      let(:to_email) { "mairie-12304-12987asdce12987asdce@blah.fr" }
      it { should eq false }
    end

    context "invalid handle" do
      let(:to_email) { "mairie-marseille@reponse.collectifobjets.org" }
      it { should eq false }
    end
  end

  describe "support_email methods" do
    let(:inbound_email) { InboundEmail.from_raw({ "To" => [{ "Address" => to_email }] }) }

    context "mairie user email" do
      let(:to_email) { "mairie-12304-12987asdce12987asdce@reply-loophole.collectifobjets.org" }

      it "should return commune_token and commune_code_insee" do
        expect(inbound_email.author_type).to eq(:user)
        expect(inbound_email.commune_token).to eq("12987asdce12987asdce")
        expect(inbound_email.commune_code_insee).to eq("12304")
      end
    end

    context "conservateur email" do
      let(:to_email) { "mairie-12304-conservateur-12987asdce12987asdce@reply-loophole.collectifobjets.org" }

      it "should return commune_token and commune_code_insee" do
        expect(inbound_email.author_type).to eq(:conservateur)
        expect(inbound_email.commune_token).to eq("12987asdce12987asdce")
        expect(inbound_email.commune_code_insee).to eq("12304")
      end
    end
  end

  describe "author" do
    let!(:bdr) { create(:departement, code: "13") }
    let!(:ile) { create(:departement, code: "01") }
    let!(:armor) { create(:departement, code: "22") }
    let!(:aix) do
      create(:commune, inbound_email_token: "abcde1234554321abcde", code_insee: "13233", departement: bdr)
    end
    let!(:rennes) do
      create(:commune, inbound_email_token: "12345abcdeedcba54321", code_insee: "01203", departement: ile)
    end
    let!(:farid) { create(:user, commune: aix, email: "farid@mairie.fr") }
    let!(:lea) { create(:user, commune: aix, email: "lea@mairie.fr") }
    let!(:jeanne) { create(:user, commune: rennes, email: "jeanne@commune01.fr") }
    let!(:isa) { create(:conservateur, email: "isa@drac.gouv.fr", departements: [bdr, armor]) }
    let!(:nadine) { create(:conservateur, email: "nadine@drac.gouv.fr", departements: [bdr, ile]) }
    let!(:renee) { create(:conservateur, email: "renee@drac.gouv.fr", departements: [ile, armor]) }
    let(:inbound_email) do
      InboundEmail.from_raw({ "From" => { "Address" => from_email }, "To" => [{ "Address" => to_email }] })
    end
    subject { inbound_email.author }

    context "author matches lea" do
      let(:to_email) { "mairie-13233-abcde1234554321abcde@reponse.collectifobjets.org" }
      let(:from_email) { "lea@mairie.fr" }
      it { should eq lea }
    end

    context "author matches farid" do
      let(:to_email) { "mairie-13233-abcde1234554321abcde@reponse.collectifobjets.org" }
      let(:from_email) { "farid@mairie.fr" }
      it { should eq farid }
    end

    context "author matches farid but wrong commune" do
      let(:to_email) { "mairie-01203-12345abcdeedcba54321@reponse.collectifobjets.org" }
      let(:from_email) { "farid@mairie.fr" }
      it { should eq jeanne }
    end

    context "author matches isa" do
      let(:to_email) { "mairie-13233-conservateur-abcde1234554321abcde@reponse.collectifobjets.org" }
      let(:from_email) { "isa@drac.gouv.fr" }
      it { should eq isa }
    end

    context "author matches renee but wrong departement" do
      let(:to_email) { "mairie-13233-conservateur-abcde1234554321abcde@reponse.collectifobjets.org" }
      let(:from_email) { "renee@drac.gouv.fr" }
      it "should be isa or nadine" do
        expect([isa, nadine]).to include(subject)
      end
    end
  end

  describe "to_message" do
    let!(:bdr) { create(:departement, code: "13") }
    let!(:aix) do
      create(:commune, inbound_email_token: "abcde1234554321abcde", code_insee: "13233", departement: bdr)
    end
    let!(:farid) { create(:user, commune: aix, email: "farid@mairie.fr") }
    context "valid user email" do
      let(:inbound_email) do
        InboundEmail.from_raw(
          {
            "MessageId" => "<blaaah@test.local>",
            "From" => { "Address" => "farid@mairie.fr" },
            "To" => [{ "Address" => "mairie-13233-abcde1234554321abcde@reponse.collectifobjets.org" }],
            "RawHtmlBody" => "<h1>Bonjour</h1>Je suis perdu<br/>Merci<br/>Antoine d'Aix",
            "RawTextBody" => "Bonjour\nje suis perdu\nMerci\nAntoine d'Aix",
            "ExtractedMarkdownMessage" => "# Bonjour\n\nJe suis perdu\n\nMerci",
            "ExtractedMarkdownSignature" => "Antoine d'Aix"
          }
        )
      end

      it "should be able to create a message" do
        message = inbound_email.to_message
        expect(message.valid?).to eq true
        expect(message.save).to eq true
        expect(message.origin).to eq "inbound_email"
        expect(message.author).to eq farid
        expect(message.commune).to eq aix
        expect(message.inbound_email.id).to eq "<blaaah@test.local>"
      end
    end

    context "invalid mairie token" do
      let(:inbound_email) do
        InboundEmail.from_raw(
          {
            "MessageId" => "<blaaah@test.local>",
            "From" => { "Address" => "farid@mairie.fr" },
            "To" => [{ "Address" => "mairie-13233-12345678901234567890@reponse.collectifobjets.org" }],
            "RawHtmlBody" => "<h1>Bonjour</h1>Je suis perdu<br/>Merci<br/>Antoine d'Aix",
            "RawTextBody" => "Bonjour\nje suis perdu\nMerci\nAntoine d'Aix",
            "ExtractedMarkdownMessage" => "# Bonjour\n\nJe suis perdu\n\nMerci",
            "ExtractedMarkdownSignature" => "Antoine d'Aix"
          }
        )
      end

      it "should not be able to create a message" do
        message = inbound_email.to_message
        expect(message.valid?).to eq false
        expect(message.errors.key?(:commune)).to eq true
        expect(message.errors.key?(:author)).to eq true
      end
    end
  end
end

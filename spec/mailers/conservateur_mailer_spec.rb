# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples"

RSpec.describe ConservateurMailer, type: :mailer do
  describe "message_received_email" do
    let(:commune) { build(:commune, id: 10, nom: "Marseille") }
    let(:user) { build(:user, commune:) }
    let(:conservateur) { build(:conservateur, email: "nadia.riza@drac.gouv.fr") }
    let(:message) { build(:message, text: "quel est l'objet ?", author: user, commune:, created_at: 1.day.ago) }
    let(:mail) { ConservateurMailer.with(conservateur:, message:).message_received_email }

    include_examples(
      "both parts contain",
      "vous a envoyé un nouveau message"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Marseille vous a envoyé un message"
      expect(mail.to).to eq(["nadia.riza@drac.gouv.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end
end

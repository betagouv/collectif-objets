# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples"

RSpec.describe RecenseurMailer, type: :mailer do
  describe "session_code" do
    let(:commune) { build(:commune) }
    let(:recenseur) { build(:recenseur, status: :accepted, communes: [commune]) }
    let(:session_code) { build(:session_code, record: recenseur, code: "123456") }
    let(:mail) { RecenseurMailer.with(session_code:).session_code }

    include_examples(
      "both parts contain",
      "Voici votre lien de connexion à Collectif Objets"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Code de connexion"
      expect(mail.to).to eq([recenseur.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end
end

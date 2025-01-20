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

  describe "access_granted" do
    let(:new_access) { create(:recenseur_access, :newly_granted) }
    let(:recenseur) { create(:recenseur, status: :accepted, accesses: [new_access]) }
    let(:session_code) { build(:session_code, record: recenseur, code: "123456") }
    let(:mail) { RecenseurMailer.with(recenseur:).access_granted }

    include_examples(
      "both parts contain",
      "Nous vous invitons à participer au recensement"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Vous avez été autorisé à participer au recensement sur Collectif Objets"
      expect(mail.to).to eq([recenseur.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "access_revoked" do
    let(:recenseur) { build(:recenseur, status: :accepted) }
    let(:mail) { RecenseurMailer.with(email: recenseur.email, nom: recenseur.nom).access_revoked }

    include_examples(
      "both parts contain",
      "Votre accès à Collectif Objets a été supprimé"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Votre accès à Collectif Objets a été supprimé"
      expect(mail.to).to eq([recenseur.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end
end

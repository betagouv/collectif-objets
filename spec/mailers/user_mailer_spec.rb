# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples"

RSpec.describe UserMailer, type: :mailer do
  describe "session_code_email" do
    let(:user) { build(:user, email: "jean@user.fr") }
    let(:session_code) { build(:session_code, user:, code: "123456") }
    let(:mail) { UserMailer.with(session_code:).session_code_email }

    include_examples(
      "both parts contain",
      "Voici votre lien de connexion à Collectif Objets"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Code de connexion"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "commune_completed_email" do
    let(:dossier) { create(:dossier, :submitted) }
    let(:commune) { create(:commune, nom: "Marseille", dossier:) }
    let(:user) { create(:user, email: "jean@user.fr", commune:) }
    let(:mail) { UserMailer.with(user:, commune:).commune_completed_email }

    include_examples(
      "both parts contain",
      "Nous vous remercions pour votre engagement"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Marseille, merci dʼavoir contribué à Collectif Objets"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "dossier_accepted" do
    let(:commune) { create(:commune, nom: "Marseille") }
    let(:user) { build(:user, email: "jean@user.fr", commune:) }
    let(:conservateur) { build(:conservateur, email: "marc@conservateur.fr") }
    let(:dossier) { build(:dossier, commune:, conservateur:) }
    let(:mail) { UserMailer.with(dossier:).dossier_accepted_email }

    before { allow(commune).to receive(:users).and_return([user]) }

    include_examples(
      "both parts contain",
      "Vous avez envoyé un dossier de recensement"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Examen du recensement des objets protégés de Marseille"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "dossier_auto_submitted_email" do
    let(:commune) { create(:commune, nom: "Marseille") }
    let(:user) { create(:user, email: "jean@user.fr", commune:) }
    let(:mail) { UserMailer.with(user:, commune:).dossier_auto_submitted_email }

    include_examples(
      "both parts contain",
      "Votre dossier était en attente de clôture"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Vos recensements d'objets ont été transmis aux conservateurs"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "relance_dossier_incomplet" do
    let(:commune) { create(:commune, nom: "Marseille") }
    let(:user) { create(:user, email: "jean@user.fr", commune:) }
    let(:mail) { UserMailer.with(user:, commune:).relance_dossier_incomplet }

    include_examples(
      "both parts contain",
      "expirera dans 3 mois"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Plus que 3 mois pour pour finaliser votre recensement"
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "derniere_relance_dossier_incomplet" do
    let(:commune) { create(:commune, nom: "Marseille") }
    let(:user) { create(:user, email: "jean@user.fr", commune:) }
    let(:mail) { UserMailer.with(user:, commune:).derniere_relance_dossier_incomplet }

    include_examples(
      "both parts contain",
      "expirera dans 30 jours"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Plus qu'un mois pour pour finaliser votre recensement"
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end

  describe "message_received_email" do
    let!(:commune) { create(:commune, id: 10, nom: "Marseille") }
    let(:user) { build(:user, email: "jean@user.fr", commune:) }
    let(:conservateur) { build(:conservateur, first_name: "Nadia", last_name: "Riza") }
    let(:message) { build(:message, text: "quel est l'objet ?", author: conservateur, created_at: 1.day.ago, commune:) }
    let(:mail) { UserMailer.with(user:, message:).message_received_email }

    include_examples(
      "both parts contain",
      "vous a envoyé un message sur Collectif Objets"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Nadia Riza vous a envoyé un message sur Collectif Objets"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end
end

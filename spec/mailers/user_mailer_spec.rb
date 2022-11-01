# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples"

# rubocop:disable Metrics/BlockLength
RSpec.describe UserMailer, type: :mailer do
  describe "validate_email" do
    let(:user) { build(:user, email: "jean@user.fr", login_token: "asdfjk29") }
    let(:mail) { UserMailer.validate_email(user) }

    include_examples(
      "both parts contain",
      "Voici votre lien de connexion à Collectif Objets"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Votre lien de connexion"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end

  describe "commune_completed_email" do
    let(:commune) { create(:commune, nom: "Marseille") }
    let(:user) { create(:user, email: "jean@user.fr", commune:) }
    let(:mail) { UserMailer.with(user_id: user.id, commune_id: commune.id).commune_completed_email }

    include_examples(
      "both parts contain",
      "Nous vous remercions pour votre engagement"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Marseille, merci dʼavoir contribué à Collectif Objets"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end

  describe "dossier_accepted" do
    let(:commune) { build(:commune, nom: "Marseille") }
    let(:user) { build(:user, email: "jean@user.fr", commune:) }
    let(:conservateur) { build(:conservateur, email: "marc@conservateur.fr") }
    let(:dossier) { build(:dossier, commune:, conservateur:) }
    let(:mail) { UserMailer.with(dossier:).dossier_accepted_email }

    before { allow(commune).to receive(:users).and_return([user]) }

    include_examples(
      "both parts contain",
      "Vous trouverez sur Collectif Objets le rapport de recensement"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Rapport de recensement des objets protégés de Marseille"
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end

  describe "dossier_rejected" do
    let(:commune) { build(:commune, nom: "Marseille") }
    let(:user) { build(:user, email: "jean@user.fr", commune:) }
    let(:conservateur) { build(:conservateur, email: "marc@conservateur.fr") }
    let(:dossier) { build(:dossier, commune:, conservateur:) }
    let(:mail) { UserMailer.with(dossier:).dossier_rejected_email }

    before { allow(commune).to receive(:users).and_return([user]) }

    include_examples(
      "both parts contain",
      "Malheureusement, les conservateurs ne sont pas en mesure de lʼanalyser en lʼétat"
    )

    it "behaves as expected" do
      expect(mail.subject).to include(
        "Compléments nécessaires pour le dossier de recensement des objets protégés de Marseille"
      )
      expect(mail.to).to eq(["jean@user.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end
end
# rubocop:enable Metrics/BlockLength

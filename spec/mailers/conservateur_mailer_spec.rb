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
      expect(mail.to).to eq([conservateur.email])
      expect(mail.from).to eq([commune.support_email(role: :conservateur)])
    end
  end

  describe "activite_email" do
    let(:departement) { create(:departement) }
    let(:conservateur) { create(:conservateur, departements: [departement]) }
    let(:commune) { create(:commune, departement:) }
    let(:dossier) { create(:dossier, :submitted, commune:) }
    let(:date_start) { dossier.submitted_at.at_beginning_of_week }
    let(:date_end) { date_start.at_end_of_week }
    let(:mail) do
      ConservateurMailer.with(conservateur_id: conservateur.id, departement_code: departement.code,
                              date_start:, date_end:).activite_email
    end

    include_examples(
      "both parts contain",
      "activité des communes"
    )

    it "behaves as expected" do
      expect(mail.subject).to include "Récapitulatif d'activité"
      expect(mail.to).to eq([conservateur.email])
      expect(mail.from).to eq([CONTACT_EMAIL])
    end
  end
end

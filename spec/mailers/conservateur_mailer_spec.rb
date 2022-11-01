# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples"

RSpec.describe ConservateurMailer, type: :mailer do
  let(:commune) { build(:commune, nom: "Joinville", id: 101) }
  let(:conservateur) { build(:conservateur, email: "jean@conservateur.fr") }
  let(:dossier) { build(:dossier, commune:, conservateur:, rejected_at: 10.days.ago) }

  before do
    expect(dossier).to receive(:recensements).at_least(:once).and_return(double(count: 10))
  end

  describe "commune_recompleted_email" do
    let(:mail) { ConservateurMailer.with(dossier:).commune_recompleted_email }

    include_examples(
      "both parts contain",
      "La commune Joinville a modifié et renvoyé son dossier de recensement de 10 objet(s) protégé(s)."
    )

    it "behaves as expected" do
      expect(mail.subject).to eq "Joinville vous a retourné le dossier de recensement"
      expect(mail.to).to eq(["jean@conservateur.fr"])
      expect(mail.from).to eq(["collectifobjets@beta.gouv.fr"])
    end
  end
end

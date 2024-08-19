# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepartementActiviteJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  describe "#date_start" do
    context "quand on est lundi" do
      it "renvoie le lundi d'avant" do
        travel_to Time.zone.local(2024, 8, 12) # Monday
        expect(described_class.date_start.monday?).to eq true
      end
    end
    context "quand on est dimanche" do
      it "renvoie le lundi de la semaine passée" do
        travel_to Time.zone.local(2024, 8, 11) # Sunday
        expect(described_class.date_start.monday?).to eq true
      end
    end
  end

  describe "#perform" do
    context "quand un département a de l'activité" do
      let(:date_start) { described_class.date_start }
      let(:date_end) { described_class.date_end }
      let(:conservateur) { instance_double("Conservateur", id: 1).id }
      let(:departement) { instance_double("Departement", code: "01").code }
      before do
        allow(Departement).to receive(:with_activity_in)
          .with(date_start..date_end)
          .and_return({ departement.code => [conservateur.id] })
      end
      it "envoie un mail à chaque conservateur" do
        expect do
          described_class.perform_now
        end.to have_enqueued_mail(ConservateurMailer, :activite_email).once.with(
          params: { conservateur_id: conservateur.id, departement_code: departement.code,
                    date_start:, date_end: }, args: []
        )
      end
    end
  end
end

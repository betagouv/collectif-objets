# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemovePersonalInformationJob, type: :job do
  describe "#perform" do
    it "removes personal information and resets updated_at" do
      recenseur = "Grace Hopper"
      dossier = create(:dossier, created_at: 6.years.ago, updated_at: 2.years.ago, recenseur:)
      expect do
        subject.perform(dossier.id)
        dossier.reload
      end.to  change(dossier, :recenseur).from(recenseur).to(nil)
         .and change(dossier, :updated_at)
    end
  end
end

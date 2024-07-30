# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScheduleRemovePersonalInformationJob, type: :job do
  describe "#dossiers" do
    it "selects the appropriate dossiers" do
      create(:dossier, created_at: 6.years.ago, recenseur: nil)
      create(:dossier, created_at: 5.years.ago, recenseur: "Jean Bartik")
      dossiers = [create(:dossier, created_at: 6.years.ago, recenseur: "Grace Hopper")]
      expect(described_class.dossiers).to eq dossiers
    end
  end
end

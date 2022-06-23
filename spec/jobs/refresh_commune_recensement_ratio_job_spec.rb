# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

RSpec.describe RefreshCommuneRecensementRatioJob, type: :job do
  describe "#perform" do
    let!(:commune) { create(:commune) }

    subject do
      RefreshCommuneRecensementRatioJob.perform_inline(commune.id)
      commune.reload.recensement_ratio
    end

    context "single commune without objets" do
      it { should be_nil }
    end

    context "single commune with objets and no recensements" do
      let!(:objet1) { create(:objet, commune:) }
      let!(:objet2) { create(:objet, commune:) }
      it { should eq 0 }
    end

    context "single commune with objets and half recensements" do
      let!(:objet1) { create(:objet, commune:) }
      let!(:objet2) { create(:objet, commune:) }
      let!(:recensement1) { create(:recensement, objet: objet1) }
      it { should eq 50 }
    end

    context "single commune with objets and half recensements" do
      let!(:objet1) { create(:objet, commune:) }
      let!(:objet2) { create(:objet, commune:) }
      let!(:recensement1) { create(:recensement, objet: objet1) }
      let!(:recensement2) { create(:recensement, objet: objet2) }
      it { should eq 100 }
    end
  end
end

# rubocop:enable Metrics/BlockLength

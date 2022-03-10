# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recensement, type: :model do
  describe "validations" do
    subject { recensement.valid? }

    context "basic recensement from factory" do
      let(:recensement) { build(:recensement) }
      it { should eq true }
    end

    context "recensement without etat_sanitaire" do
      let(:recensement) { build(:recensement, etat_sanitaire: nil) }
      it { should eq false }
    end

    context "recensement autre edifice with edifice_nom" do
      let(:recensement) do
        build(:recensement, localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: "blah")
      end
      it { should eq true }
    end

    context "recensement autre edifice without edifice_nom" do
      let(:recensement) { build(:recensement, localisation: Recensement::LOCALISATION_AUTRE_EDIFICE, edifice_nom: nil) }
      it { should eq false }
    end
  end
end

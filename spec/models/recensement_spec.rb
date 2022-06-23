# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength

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

  describe "prevent analyse override equal to original" do
    let!(:recensement) do
      build(:recensement, etat_sanitaire:, analyse_etat_sanitaire:)
    end

    subject do
      recensement.update!(analyse_etat_sanitaire: new_analyse_etat_sanitaire)
      recensement.reload.analyse_etat_sanitaire
    end

    context "trying to set initial override value" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { nil }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      it { should eq Recensement::ETAT_MAUVAIS }
    end

    context "trying to set initial override value to same as original" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { nil }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_BON }
      it { should eq nil }
    end

    context "trying to change override value" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { Recensement::ETAT_MOYEN }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      it { should eq Recensement::ETAT_MAUVAIS }
    end

    context "trying to change override value to same as original" do
      let(:etat_sanitaire) { Recensement::ETAT_BON }
      let(:analyse_etat_sanitaire) { Recensement::ETAT_MAUVAIS }
      let(:new_analyse_etat_sanitaire) { Recensement::ETAT_BON }
      it { should eq nil }
    end
  end
end
# rubocop:enable Metrics/BlockLength

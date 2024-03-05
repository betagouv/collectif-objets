# frozen_string_literal: true

require "rails_helper"

describe Departement, type: :model do
  describe "#parse_from_code_insee" do
    subject { Departement.parse_from_code_insee(code_insee) }
    context "Paris" do
      let(:code_insee) { "75056" }
      it { is_expected.to eq "75" }
    end

    context "martinique - fort de france" do
      let(:code_insee) { "97209" }
      it { is_expected.to eq "972" }
    end

    context "09 - Ariège" do
      let(:code_insee) { "09001" }
      it { is_expected.to eq "09" }
    end

    context "ajaccio" do
      let(:code_insee) { "2A004" }
      it { is_expected.to eq "2A" }
    end

    context "nil" do
      let(:code_insee) { nil }
      it { is_expected.to eq nil }
    end
  end
end

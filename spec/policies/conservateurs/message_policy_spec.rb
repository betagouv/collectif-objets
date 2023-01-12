# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::MessagePolicy do
  subject { described_class }

  permissions :create? do
    context "message d'une commune d'un departement du conservateur" do
      let(:departements) { build_list(:departement, 3) }
      let(:commune) { build(:commune, departement: departements[1]) }
      let(:conservateur) { build(:conservateur, departements:) }
      let(:message) { build(:message, commune:) }
      it { should permit(conservateur, message) }
    end

    context "autre departement" do
      let(:departements) { build_list(:departement, 3) }
      let(:commune) { build(:commune, departement: build(:departement)) }
      let(:conservateur) { build(:conservateur, departements:) }
      let(:message) { build(:message, commune:) }
      it { should_not permit(conservateur, message) }
    end
  end
end

describe Conservateurs::MessagePolicy::Scope do
  context "quelques departements" do
    let!(:departements1) { create_list(:departement, 2) }
    let!(:communes1a) { create_list(:commune, 2, departement: departements1[0]) }
    let!(:messages1a) { create_list(:message, 2, commune: communes1a[0]) }
    let!(:communes1b) { create_list(:commune, 2, departement: departements1[1]) }
    let!(:messages1b) { create_list(:message, 2, commune: communes1b[0]) }
    let!(:departements2) { create_list(:departement, 2) }
    let!(:communes2a) { create_list(:commune, 2, departement: departements2[0]) }
    let!(:messages2a) { create_list(:message, 2, commune: communes2a[0]) }
    let!(:communes2b) { create_list(:commune, 2, departement: departements2[1]) }
    let!(:messages2b) { create_list(:message, 2, commune: communes2b[0]) }
    let!(:conservateur) { create(:conservateur, departements: departements1) }

    it "renvoie les messages des communes des departements du conservateur" do
      communes = described_class.new(conservateur, Message).resolve
      expect(communes.count).to eq 4
      expect(communes).to include messages1a[0]
      expect(communes).to include messages1a[1]
      expect(communes).to include messages1b[0]
      expect(communes).to include messages1b[1]
      expect(communes).not_to include messages2a[0]
      expect(communes).not_to include messages2a[1]
      expect(communes).not_to include messages2b[0]
      expect(communes).not_to include messages2b[1]
    end
  end
end

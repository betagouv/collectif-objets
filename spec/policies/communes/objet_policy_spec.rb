# frozen_string_literal: true

require "rails_helper"

describe Communes::ObjetPolicy do
  subject { described_class }

  permissions :show? do
    context "objet de la commune du user" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:objet) { build(:objet, commune:) }
      let(:user) { build(:user, commune:) }

      it { should permit(user, objet) }
    end

    context "objet d'une autre commune" do
      let(:commune1) { build(:commune, status: :inactive) }
      let(:commune2) { build(:commune, status: :inactive) }
      let(:objet) { build(:objet, commune: commune1) }
      let(:user) { build(:user, commune: commune2) }

      it { should_not permit(user, objet) }
    end
  end
end

describe Communes::ObjetPolicy::Scope do
  context "4 objets de differentes communes" do
    let!(:commune1) { create(:commune, status: :inactive) }
    let!(:commune2) { create(:commune, status: :inactive) }
    let!(:objets1) { create_list(:objet, 2, commune: commune1) }
    let!(:objets2) { create_list(:objet, 2, commune: commune2) }
    let!(:user1) { create(:user, commune: commune1) }
    let!(:user2) { create(:user, commune: commune2) }

    it "renvoie les objets de la commune du user" do
      objets = described_class.new(user1, Objet.all).resolve
      expect(objets.count).to eq 2
      expect(objets).to include objets1[0]
      expect(objets).to include objets1[1]
      expect(objets).not_to include objets2[0]
      expect(objets).not_to include objets2[1]
    end
  end
end

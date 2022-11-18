# frozen_string_literal: true

require "rails_helper"

describe Communes::FormulaireImprimablePolicy do
  subject { described_class }

  permissions :show?, :enqueue_generate_pdf? do
    context "commune du user + inactive" do
      let(:commune) { build(:commune, status: :inactive) }
      let(:formulaire_imprimable) { FormulaireImprimable.new(commune:) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, formulaire_imprimable) }
    end

    context "commune du user + started" do
      let(:commune) { build(:commune, status: :started) }
      let(:formulaire_imprimable) { FormulaireImprimable.new(commune:) }
      let(:user) { build(:user, commune:) }
      it { should permit(user, formulaire_imprimable) }
    end

    context "commune du user + completed" do
      let(:commune) { build(:commune, status: :completed) }
      let(:formulaire_imprimable) { FormulaireImprimable.new(commune:) }
      let(:user) { build(:user, commune:) }
      it { should_not permit(user, formulaire_imprimable) }
    end

    context "autre commune" do
      let(:commune1) { build(:commune, status: :inactive) }
      let(:commune2) { build(:commune, status: :inactive) }
      let(:formulaire_imprimable) { FormulaireImprimable.new(commune: commune1) }
      let(:user) { build(:user, commune: commune2) }
      it { should_not permit(user, formulaire_imprimable) }
    end
  end
end

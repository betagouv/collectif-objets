# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::AnalysePolicy do
  subject { described_class }

  permissions :edit?, :update? do
    context "analyse d'une commune completed d'un departement du conservateur" do
      let(:commune) { build(:commune, status: :completed) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [analyse.departement]) }
      it { should permit(conservateur, analyse) }
    end

    context "analyse d'une commune started" do
      let(:commune) { build(:commune, status: :started) }
      let(:objet) { build(:objet, commune:) }
      let(:recensement) { build(:recensement, objet:) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3) + [analyse.departement]) }
      it { should_not permit(conservateur, analyse) }
    end

    context "analyse d'une commune d'un autre departement" do
      let(:recensement) { build(:recensement) }
      let(:analyse) { Analyse.new(recensement:) }
      let(:conservateur) { build(:conservateur, departements: build_list(:departement, 3)) }
      it { should_not permit(conservateur, analyse) }
    end

    # context "analyse d'un autre departement" do
    #   let(:departements) { build_list(:departement, 3) }
    #   let(:commune) { build(:commune, departement: build(:departement)) }
    #   let(:conservateur) { build(:conservateur, departements:) }
    #   it { should_not permit(conservateur, commune) }
    # end
  end
end

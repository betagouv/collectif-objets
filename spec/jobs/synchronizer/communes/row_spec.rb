# frozen_string_literal: true

require "rails_helper"

describe Synchronizer::Communes::Row do
  let(:base_csv_row) do
    {
      "pivot" => "[{\"type_service_local\":\"mairie\"}]",
      "code_insee_commune" => "01001",
      "nom" => "Mairie - Ambérieu",
      "telephone" => "[{\"valeur\":\"01 02 03 04 05\"}]",
      "adresse_courriel" => "contact@amberieu.fr"
    }
  end
  let(:row) { described_class.new(csv_row) }
  before { row.valid? } # trigger validations

  context "mairie classique" do
    let(:csv_row) { base_csv_row }
    it "est dans le scope" do
      expect(row.errors).to be_empty
      expect(row.in_scope?).to eq true
    end
  end

  context "pivot hopital" do
    let(:csv_row) do
      base_csv_row.merge({ "pivot" => "[{\"type_service_local\":\"hopital\"}]" })
    end
    it "n’est pas dans le scope" do
      expect(row.in_scope?).to eq false
      expect(row.errors).to include(:type_service_local)
    end
  end

  context "mairie annexe" do
    let(:csv_row) do
      base_csv_row.merge({ "nom" => "Mairie Annexe - Ambérieu" })
    end
    it "n’est pas dans le scope" do
      expect(row.in_scope?).to eq false
      expect(row.errors).to include(:nom)
    end
  end
end

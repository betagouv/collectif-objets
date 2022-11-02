# frozen_string_literal: true

require "rails_helper"

RSpec.describe Co::Recensements::ParamsParser do
  let(:raw_recensement_params) do
    {
      analyse_etat_sanitaire: "bon",
      analyse_etat_sanitaire_edifice: "moyen",
      analyse_securisation: "en_securite",
      analyse_notes: "merci",
      analyse_actions: %w[],
      analyse_fiches: %w[]
    }
  end

  let(:request_params) { ActionController::Parameters.new({ recensement: raw_recensement_params }) }

  subject { Co::Recensements::AnalyseParamsParser.new(request_params).parse }

  context "basic" do
    it "should be ok" do
      res = subject
      expect(res[:analyse_etat_sanitaire]).to eq "bon"
      expect(res[:analyse_etat_sanitaire_edifice]).to eq "moyen"
      expect(res[:analyse_securisation]).to eq "en_securite"
      expect(res[:analyse_notes]).to eq "merci"
      expect(res[:analyse_actions]).to eq %w[]
      expect(res[:analyse_fiches]).to eq %w[]
    end
  end

  context "analyse actions has blank values" do
    before { raw_recensement_params.merge!(analyse_actions: ["blah", nil, "thing", ""]) }
    it "should clear blank values" do
      res = subject
      expect(res[:analyse_actions]).to eq %w[blah thing]
    end
  end
end

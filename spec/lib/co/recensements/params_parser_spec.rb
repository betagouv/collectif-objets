# frozen_string_literal: true

require "rails_helper"

RSpec.describe Co::Recensements::AnalyseParamsParser do
  let(:raw_recensement_params) do
    {
      confirmation: "1",
      localisation: "edifice_initial",
      recensable: "true",
      etat_sanitaire: "bon",
      etat_sanitaire_edifice: "bon",
      securisation: "en_securite",
      notes: "blah blah",
      skip_photos: "1"
    }
  end

  let(:request_params) { ActionController::Parameters.new({ recensement: raw_recensement_params }) }

  subject { Co::Recensements::ParamsParser.new(request_params).parse }

  context "basic" do
    it "should be ok" do
      res = subject
      expect(res[:confirmation]).to eq true
      expect(res[:localisation]).to eq "edifice_initial"
      expect(res[:recensable]).to eq true
      expect(res[:etat_sanitaire]).to eq "bon"
      expect(res[:etat_sanitaire_edifice]).to eq "bon"
      expect(res[:securisation]).to eq "en_securite"
      expect(res[:notes]).to eq "blah blah"
      expect(res[:skip_photos]).to eq true
    end
  end

  context "confirmation" do
    before { raw_recensement_params.delete(:confirmation) }

    it "should have confirmation false" do
      res = subject
      expect(res[:confirmation]).to eq false
    end
  end

  context "recensable false" do
    before { raw_recensement_params.merge!(recensable: "false") }

    it "should have overriden many things" do
      res = subject
      expect(res[:confirmation]).to eq true
      expect(res[:recensable]).to eq false
      expect(res[:etat_sanitaire]).to eq nil
      expect(res[:etat_sanitaire_edifice]).to eq nil
      expect(res[:securisation]).to eq nil
      expect(res[:photos]).to eq []
    end
  end

  context "localisation absent" do
    before { raw_recensement_params.merge!(localisation: "absent") }

    it "should have overriden many things" do
      res = subject
      expect(res[:confirmation]).to eq true
      expect(res[:recensable]).to eq false
      expect(res[:etat_sanitaire]).to eq nil
      expect(res[:etat_sanitaire_edifice]).to eq nil
      expect(res[:securisation]).to eq nil
      expect(res[:photos]).to eq []
    end
  end
end

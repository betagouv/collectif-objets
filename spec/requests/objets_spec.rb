# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Objets", type: :request do
  describe "/objets?commune_code_insee=12345" do
    it "redirige vers communes/54321" do
      commune = create(:commune, code_insee: 12_345)
      get("/objets?commune_code_insee=#{commune.code_insee}")
      expect(response).to redirect_to("/communes/#{commune.id}")
    end
  end

  describe "/objets" do
    it "affiche une erreur 404" do
      get("/objets?commune_code_insee=123")
      expect(response).to have_http_status(:not_found)
    end
  end
end

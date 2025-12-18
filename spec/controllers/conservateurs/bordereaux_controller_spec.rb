# frozen_string_literal: true

require "rails_helper"

describe Conservateurs::BordereauxController, type: :controller do
  let(:departement) { create(:departement) }
  let(:conservateur) { create(:conservateur, departements: [departement]) }
  let(:commune) { create(:commune, departement:) }
  let(:dossier) { create(:dossier, :accepted, commune:, conservateur:) }
  let(:edifice) { create(:edifice, commune:) }
  let!(:objet) { create(:objet, :classé, :with_palissy_photo, edifice:) }
  let!(:recensement) { create(:recensement, :examiné, objet:, dossier:) }
  let(:bordereau) { create(:bordereau, dossier:, edifice:) }

  before do
    sign_in conservateur
    # Stub external photo requests with a real fixture image
    stub_request(:get, %r{https://example.com/demo/objets/.*\.jpg})
      .to_return(
        status: 200,
        body: Rails.root.join("spec/fixture_files/peinture1.jpg"),
        headers: { "Content-Type" => "image/jpeg" }
      )
  end

  describe "GET #show" do
    context "when file exists" do
      before do
        bordereau.generate_pdf
      end

      it "redirects to the blob path" do
        get :show, params: { commune_id: commune.id, id: bordereau.id }
        expect(response).to redirect_to(rails_blob_path(bordereau.file, disposition: "attachment"))
      end
    end

    context "when file is missing" do
      before do
        # Simulate a missing file by creating attachment and then purging the blob
        bordereau.file.attach(io: StringIO.new("test"), filename: "test.pdf")
        blob = bordereau.file.blob
        bordereau.file.purge
        # Delete the blob to simulate ActiveStorage::FileNotFoundError
        blob.delete if blob.persisted?
      end

      it "regenerates the PDF and redirects" do
        expect(bordereau.file.attached?).to be false

        get :show, params: { commune_id: commune.id, id: bordereau.id }

        expect(bordereau.reload.file.attached?).to be true
        expect(response).to redirect_to(rails_blob_path(bordereau.reload.file, disposition: "attachment"))
      end
    end
  end
end

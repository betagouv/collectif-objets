# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Active Storage safe purge monkey patches" do
  let(:local_blob) do
    ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join("spec/fixture_files/peinture1.jpg").open("rb"),
      filename: "peinture1.jpg",
      content_type: "image/jpeg"
    )
  end

  before do
    class << local_blob
      include RSpec::Mocks::ExampleMethods
      def service
        @service ||= double("active_storage_service")
      end
    end
  end

  context "blob uses local service" do
    let(:blob) { local_blob }
    it "should delete the blob" do
      expect(blob.service).to receive(:delete)
      expect(blob.service).to receive(:delete_prefixed)
      res = blob.delete
      expect(res).not_to eq(false)
    end
  end

  context "blob uses prod service" do
    let(:blob) { local_blob.tap { _1.update!(service_name: "scaleway_production") } }
    it "should not delete the blob" do
      expect(blob.service).not_to receive(:delete)
      expect(blob.service).not_to receive(:delete_prefixed)
      res = blob.delete
      expect(res).to eq(false)
    end
  end
end

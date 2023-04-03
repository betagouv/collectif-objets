# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CreateMagicLinkService, type: :service do
  describe "#perform" do
    let!(:user) { create(:user) }

    subject { Users::CreateMagicLinkService.new(email).perform }

    context "success" do
      let(:email) { user.email }

      it { should eq({ success: true, error: nil }) }
    end

    context "no user found" do
      let(:email) { "weird@email.fr" }

      it { should eq({ success: false, error: :no_user_found }) }
    end
  end
end

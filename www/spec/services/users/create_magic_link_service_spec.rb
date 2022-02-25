# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CreateMagicLinkService, type: :service do
  describe "#perform" do
    subject { Users::CreateMagicLinkService.new(email).perform }

    context "success" do
      let!(:user) { create(:user) }
      let(:email) { user.email }

      before do
        expect(User).to receive(:find_by).with(email:).and_return(user)
        expect(user).to receive(:rotate_login_token).and_return(true)
        mailer_double = double(deliver_now: true)
        # expect(mailer_double).to receive(:deliver_now)
        expect(UserMailer).to receive(:validate_email).with(user).and_return(mailer_double)
      end
      it { should eq({ success: true, error: nil }) }
    end

    context "no user found" do
      let!(:user) { create(:user) }
      let(:email) { "weird@email.fr" }

      before do
        expect(UserMailer).not_to receive(:validate_email)
      end
      it { should eq({ success: false, error: :no_user_found }) }
    end
  end
end

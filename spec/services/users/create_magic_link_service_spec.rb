# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CreateMagicLinkService, type: :service do
  describe "#perform" do
    context "matching email" do
      let!(:user) { create(:user, email: "jean@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { Users::CreateMagicLinkService.new("jean@valjean.fr").perform }

      before do
        mailer_double = double(deliver_now: true)
        expect(mailer_double).to receive(:deliver_now)
        expect(UserMailer).to receive(:validate_email).and_return(mailer_double)
      end

      it "should work" do
        res = subject
        expect(res).to eq({ success: true, error: nil })
        expect(user.reload.login_token).not_to be_nil
        expect(user.reload.login_token_valid_until).to be > Time.zone.now
      end
    end

    context "matching email but different capitalization" do
      let!(:user) { create(:user, email: "jean@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { Users::CreateMagicLinkService.new("JEAN@valjean.fr").perform }

      before do
        mailer_double = double(deliver_now: true)
        expect(mailer_double).to receive(:deliver_now)
        expect(UserMailer).to receive(:validate_email).and_return(mailer_double)
      end

      it "should work" do
        res = subject
        expect(res).to eq({ success: true, error: nil })
        expect(user.reload.login_token).not_to be_nil
        expect(user.reload.login_token_valid_until).to be > Time.zone.now
      end
    end

    context "mismatching emails" do
      let!(:user) { create(:user, email: "martine@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { Users::CreateMagicLinkService.new("jean@valjean.fr").perform }

      before do
        expect(UserMailer).not_to receive(:validate_email)
      end
      it { should eq({ success: false, error: :no_user_found }) }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe MagicLink, type: :service do
  describe "#create" do
    context "matching email" do
      let!(:user) { create(:user, email: "jean@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { MagicLink.new("jean@valjean.fr").create }

      it "should update login token" do
        res = subject
        expect(res).to eq({ success: true, error: nil })
        expect(user.reload.login_token).not_to be_nil
        expect(user.reload.login_token_valid_until).to be > Time.zone.now
      end

      it "should send an email" do
        expect { subject }.to have_enqueued_email(UserMailer, :validate_email)
      end
    end

    context "matching email but different capitalization" do
      let!(:user) { create(:user, email: "jean@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { MagicLink.new("JEAN@valjean.fr").create }

      it "should work" do
        res = subject
        expect(res).to eq({ success: true, error: nil })
        expect(user.reload.login_token).not_to be_nil
        expect(user.reload.login_token_valid_until).to be > Time.zone.now
      end

      it "should send an email" do
        expect { subject }.to have_enqueued_email(UserMailer, :validate_email)
      end
    end

    context "mismatching emails" do
      let!(:user) { create(:user, email: "martine@valjean.fr", login_token: nil, login_token_valid_until: nil) }
      subject { MagicLink.new("jean@valjean.fr").create }

      it { should eq({ success: false, error: :no_user_found }) }

      it "should not send an email" do
        expect { subject }.not_to have_enqueued_email(UserMailer, :validate_email)
      end
    end
  end
end

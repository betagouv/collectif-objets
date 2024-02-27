# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionAuthentication do
  let(:session_authentication) { SessionAuthentication.new(email, code) }
  let!(:user) { create(:user, email: "jean@delafontaine.fr") }
  let!(:session_code) { instance_double(SessionCode, code: "123456", expired?: expired, used?: used) }
  let(:expired) { false }
  let(:used) { false }
  before { allow(user).to receive(:last_session_code).and_return(session_code) }

  subject { session_authentication.authenticate }

  context "missing email" do
    let(:email) { "" }
    let(:code) { "123456" }
    it { should eq false }
    it "should not yield" do
      expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
    end
    it "should have blank attribute error" do
      subject
      error = session_authentication.errors.first
      expect(error).to have_attributes(attribute: :email, type: :blank)
    end
  end

  context "missing code" do
    let(:email) { "jean@delafontaine.fr" }
    let(:code) { "" }
    it { should eq false }
    it "should not yield" do
      expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
    end
    it "should have blank attribute error" do
      subject
      error = session_authentication.errors.first
      expect(error).to have_attributes(attribute: :code, type: :blank)
    end
  end

  context "no user found" do
    context "no matching user for email" do
      let(:email) { "patoche@test.fr" }
      let(:code) { "123456" }
      it { should eq false }
      it "should not yield" do
        expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
      end
      it "should have user not found error" do
        subject
        error = session_authentication.errors.first
        expect(error).to have_attributes(attribute: :user, type: :blank)
        expect(session_authentication.error_message).to eq "Aucun utilisateur trouvé pour cet email"
      end
    end
  end

  context "user found" do
    before do
      allow(User).to receive(:find_by).and_return(user)
      # allow(user).to receive(:valid_session_code?).and_return(valid_session_code)
    end

    let(:subject) { session_authentication.authenticate { true } }

    context "everything works out" do
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "123456" }
      it "should yield" do
        expect { |b| session_authentication.authenticate(&b) }.to yield_control
      end
      it "should work" do
        expect(session_code).to receive(:mark_used!)
        subject
        expect(session_authentication.errors).to be_empty
      end
    end

    context "correct code but contains spaces" do
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "  1 23 4 5 6  " }
      it "should yield" do
        expect { |b| session_authentication.authenticate(&b) }.to yield_control
      end
      it "should work" do
        expect(session_code).to receive(:mark_used!)
        res = subject
        expect(res).to eq true
        expect(session_authentication.errors).to be_empty
      end
    end

    context "code is expired" do
      let(:expired) { true }
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "123456" }

      it { should eq false }
      it "should not yield" do
        expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
      end
      it "should have expired code error" do
        subject
        error = session_authentication.errors.first
        expect(error).to have_attributes(attribute: :code, type: :expired)
        expect(session_authentication.error_message).to eq "Code de connexion expiré"
      end
    end

    context "code is used" do
      let(:used) { true }
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "123456" }

      it { should eq false }
      it "should not yield" do
        expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
      end
      it "should have used code error" do
        subject
        error = session_authentication.errors.first
        expect(error).to have_attributes(attribute: :code, type: :used)
        expect(session_authentication.error_message).to eq "Code de connexion déjà utilisé"
      end
    end

    context "codes mismatch" do
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "654321" }
      it "should not yield" do
        expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
      end
      it { should eq false }
      it "should have mismatch error" do
        subject
        error = session_authentication.errors.first
        expect(error).to have_attributes(attribute: :code, type: :mismatch)
        expect(session_authentication.error_message).to include "Code de connexion incorrect"
      end
    end

    context "codes mismatch & code expired" do
      let(:expired) { true }
      let(:email) { "jean@delafontaine.fr" }
      let(:code) { "654321" }
      it "should not yield" do
        expect { |b| session_authentication.authenticate(&b) }.not_to(yield_control)
      end
      it { should eq false }
      it "should have mismatch error but not expired code error" do
        subject
        error = session_authentication.errors.first
        expect(error).to have_attributes(attribute: :code, type: :mismatch)
        expect(session_authentication.error_message).to include "Code de connexion incorrect"
      end
    end
  end
end

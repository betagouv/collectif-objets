# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "validations" do
    it "validates presence of first_name" do
      admin_user = build(:admin_user, first_name: nil)
      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:first_name]).to be_present
    end

    it "validates presence of last_name" do
      admin_user = build(:admin_user, last_name: nil)
      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:last_name]).to be_present
    end
  end

  describe "#to_s" do
    let(:admin_user) { build_stubbed(:admin_user, first_name: "Jean", last_name: "Dupont") }

    it "returns the full name" do
      expect(admin_user.to_s).to eq "Jean Dupont"
    end
  end

  describe "#find_or_generate_otp_secret" do
    context "when user has no OTP secret" do
      let(:admin_user) { create(:admin_user, otp_secret: nil) }

      it "generates and saves a new OTP secret" do
        expect(admin_user.otp_secret).to be_nil

        result = admin_user.find_or_generate_otp_secret

        expect(result).to be_present
        expect(result).to match(/^[a-z2-7]{32}$/i)
        expect(admin_user.reload.otp_secret).to eq result
      end

      it "returns the generated secret" do
        secret = admin_user.find_or_generate_otp_secret

        expect(secret).to eq(admin_user.reload.otp_secret)
      end
    end

    context "when user already has an OTP secret" do
      let(:admin_user) { create(:admin_user) }
      let(:existing_secret) { admin_user.otp_secret }

      it "returns the existing secret without changing it" do
        result = admin_user.find_or_generate_otp_secret

        expect(result).to eq existing_secret
        expect(admin_user.reload.otp_secret).to eq existing_secret
      end

      it "does not update the record" do
        expect(admin_user).not_to receive(:update)

        admin_user.find_or_generate_otp_secret
      end
    end
  end

  describe "#enable_2fa!" do
    let(:admin_user) { create(:admin_user, otp_required_for_login: false, otp_secret: nil, otp_backup_codes: nil) }

    it "enables 2FA for the user" do
      admin_user.enable_2fa!

      expect(admin_user.reload.otp_required_for_login).to be true
      expect(admin_user.otp_secret).to be_present
      expect(admin_user.otp_backup_codes).to be_present
    end

    it "generates and returns backup codes" do
      backup_codes = admin_user.enable_2fa!

      expect(backup_codes).to be_an(Array)
      expect(backup_codes.size).to eq 10
      expect(admin_user.reload.otp_backup_codes.size).to eq 10
      expect(backup_codes).not_to eq(admin_user.otp_backup_codes)
    end

    it "stores hashed backup codes in database" do
      plaintext_codes = admin_user.enable_2fa!
      stored_codes = admin_user.reload.otp_backup_codes

      expect(stored_codes).to be_an(Array)
      expect(stored_codes.size).to eq 10
      stored_codes.each do |hashed_code|
        expect(hashed_code).to start_with("$2a$")
        expect(plaintext_codes).not_to include(hashed_code)
      end
    end

    it "allows using plaintext backup codes for authentication" do
      plaintext_codes = admin_user.enable_2fa!
      admin_user.reload

      expect(admin_user.invalidate_otp_backup_code!(plaintext_codes.first)).to be true
      expect(admin_user.reload.otp_backup_codes.size).to eq 9
      expect(admin_user.invalidate_otp_backup_code!(plaintext_codes.first)).to be false
    end

    context "when 2FA is already enabled" do
      let(:admin_user) { create(:admin_user, otp_required_for_login: true) }
      let(:old_secret) { admin_user.otp_secret }

      it "returns early without changing anything" do
        result = admin_user.enable_2fa!

        expect(result).to be_nil
        expect(admin_user.reload.otp_secret).to eq old_secret
      end
    end
  end

  describe "#disable_2fa!" do
    let(:admin_user) { create(:admin_user, otp_required_for_login: true) }

    it "disables 2FA for the user, clears OTP secret and backup codes" do
      admin_user.disable_2fa!
      admin_user.reload

      expect(admin_user.otp_required_for_login).to be false
      expect(admin_user.otp_secret).to be_nil
      expect(admin_user.otp_backup_codes).to be_nil
    end

    context "when 2FA is already disabled" do
      let(:admin_user) { create(:admin_user, otp_required_for_login: false, otp_secret: nil, otp_backup_codes: nil) }

      it "does not raise an error" do
        expect { admin_user.disable_2fa! }.not_to raise_error
      end
    end
  end

  describe "#remaining_otp_backup_codes" do
    let(:otp_backup_codes) { Array.new(10) { "a" * 15 } }

    context "when user has backup codes" do
      let(:admin_user) { build_stubbed(:admin_user, otp_backup_codes:) }

      it "returns the count of remaining backup codes" do
        expect(admin_user.remaining_otp_backup_codes).to eq 10
      end

      context "after using some backup codes" do
        let(:admin_user) { build_stubbed(:admin_user, otp_backup_codes: otp_backup_codes.take(5)) }

        it "returns the updated count" do
          expect(admin_user.remaining_otp_backup_codes).to eq 5
        end
      end
    end

    context "when user has no backup codes" do
      let(:admin_user) { build_stubbed(:admin_user, otp_backup_codes: nil) }

      it "returns 0" do
        expect(admin_user.remaining_otp_backup_codes).to eq 0
      end
    end

    context "when backup codes is an empty array" do
      let(:admin_user) { build_stubbed(:admin_user, otp_backup_codes: []) }

      it "returns 0" do
        expect(admin_user.remaining_otp_backup_codes).to eq 0
      end
    end
  end
end

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
end

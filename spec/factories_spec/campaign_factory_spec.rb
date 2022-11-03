# frozen_string_literal: true

require "rails_helper"

RSpec.describe "campaign factory", type: :factory do
  it "should work" do
    campaign = build(:campaign)
    expect(campaign.valid?).to eq true
  end

  it "should work for planned one" do
    campaign = build(:campaign, status: "planned", date_lancement: Date.new(2031, 6, 10))
    expect(campaign.valid?).to eq true
  end

  it "should let create multiple ones" do
    campaign = build(:campaign, status: "planned",
                                date_lancement: Date.new(2031, 6, 10))
    campaign.valid?
    expect(campaign.errors).to be_empty
    campaign.save!

    campaign = build(:campaign, status: "planned",
                                date_lancement: Date.new(2031, 6, 10))
    campaign.valid?
    expect(campaign.errors).to be_empty
    campaign.save!

    campaign = build(:campaign, status: "planned",
                                date_lancement: Date.new(2031, 6, 10))
    campaign.valid?
    expect(campaign.errors).to be_empty
    campaign.save!

    campaign = build(:campaign, status: "planned",
                                date_lancement: Date.new(2031, 6, 10))
    campaign.valid?
    expect(campaign.errors).to be_empty
    campaign.save!
  end
end

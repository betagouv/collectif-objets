# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recenseur, type: :model do
  describe "factory" do
    let(:recenseur) { build(:recenseur) }
    subject { recenseur.valid? }
    it { should be true }
  end
end

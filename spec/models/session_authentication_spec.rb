# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionAuthentication do
  let(:email) { "user@example.com" }
  let(:code) { "123456" }
  let(:model) { User }
  let(:user) { instance_double(User, persisted?: true) }
  let(:session_code) { instance_double(SessionCode, code:, expired?: false) }

  subject(:authentication) { described_class.new(email:, code:, model:) }

  before do
    allow(model).to receive(:find_by).with(email:).and_return(user)
    allow(user).to receive(:session_code).and_return(session_code)
    allow(session_code).to receive(:mark_used!)
    allow(SessionCode).to receive(:valid_format?).with(any_args).and_return(true)
  end

  describe ".authenticate_by" do
    subject(:authenticate) { described_class.authenticate_by(email:, code:, model:) }

    it "delegates to a new instance" do
      instance = instance_double(described_class)
      expect(described_class).to receive(:new)
        .with(email:, code:, model:)
        .and_return(instance)
      expect(instance).to receive(:authenticate)

      authenticate
    end
  end

  describe "#initialize" do
    it "strips whitespace from email" do
      auth = described_class.new(email: " user@example.com ", code:, model:)
      expect(auth.send(:email)).to eq("user@example.com")
    end

    it "removes non-digits from code" do
      auth = described_class.new(email:, code: "12-34-56", model:)
      expect(auth.send(:code)).to eq("123456")
    end
  end

  describe "#authenticate" do
    context "when valid" do
      it "marks the session code as used and returns the authenticatable" do
        expect(session_code).to receive(:mark_used!)
        result = authentication.authenticate
        expect(result).to eq(user)
      end
    end

    context "when invalid" do
      it "returns an array with nil and error message" do
        allow(model).to receive(:find_by).with(email:).and_return(nil)
        result, error = authentication.authenticate
        expect(result).to be_nil
        expect(error).to be_present
      end
    end

    it "prevents timing attacks in production" do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(authentication).to receive(:sleep).with(be_between(0.5, 1))
      authentication.authenticate
    end
  end

  describe "validations" do
    subject(:error) { authentication.errors.full_messages.first }

    before(:each) { authentication.valid? }

    describe "email presence" do
      let(:email) { "" }

      it "is invalid without an email" do
        expect(authentication).not_to be_valid
        expect(error).to eq("Email doit être rempli(e)")
      end
    end

    describe "code presence" do
      let(:code) { "" }

      it "is invalid without a code" do
        expect(authentication).not_to be_valid
        expect(error).to eq("Code doit être rempli(e)")
      end
    end

    describe "#validate_resource_found" do
      context "when authenticatable is not persisted" do
        it "adds an error" do
          allow(model).to receive(:find_by).with(email:).and_return(nil)
          authentication.valid?
          expect(authentication.errors[:email])
            .to include("Aucun compte trouvé pour cet email.")
        end
      end

      context "when authenticatable is persisted" do
        it "does not add an error" do
          allow(model).to receive(:find_by).with(email:).and_return(build(:user, email:))
          authentication.valid?
          expect(authentication.errors[:email])
            .not_to include("Aucun compte trouvé pour cet email.")
        end
      end
    end

    describe "#validate_code_format" do
      before do
        allow(SessionCode).to receive(:valid_format?).with(code).and_return(false)
        authentication.valid?
      end

      it "validates code format" do
        expect(error).to eq("Code mal saisi. Le code de connexion est composé de " \
                            "#{SessionCode::LENGTH} chiffres exactement. " \
                            "Vérifiez que vous n'avez pas copié deux fois le même chiffre.")
      end
    end

    describe "#validate_codes_match" do
      let(:session_code) { instance_double(SessionCode, code: "654321", expired?: false) }

      it "adds an error when codes don't match" do
        expect(error).to eq("Code incorrect. Vérifiez que vous avez bien recopié le code " \
                            "et qu'il provient bien du dernier mail envoyé.")
      end
    end

    describe "#validate_code_not_expired" do
      let(:session_code) { instance_double(SessionCode, code:, expired?: true) }

      it "adds an error when code is expired" do
        expect(error).to eq("Code expiré, veuillez en demander un nouveau.")
      end
    end
  end
end

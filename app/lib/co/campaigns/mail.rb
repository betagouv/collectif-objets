# frozen_string_literal: true

module Co
  module Campaigns
    class Mail
      VARIANTS = %w[inactive started to_complete].freeze

      attr_reader :user, :commune, :campaign, :step

      delegate :message, :deliver_now!, to: :email
      delegate :subject, :body, to: :message

      def initialize(user:, commune:, campaign:, step:)
        @user = user
        @commune = commune
        @campaign = campaign
        @step = step
      end

      def email_name
        [step, variant, "email"].compact.join("_")
      end

      def variant
        Co::Campaigns::Mail.variant_for(step, commune)
      end

      def email
        @email ||= CampaignV1Mailer
          .with(user:, commune:, campaign:)
          .send(email_name)
      end

      def headers
        message.header.map { [_1.name, _1.value] }.to_h
      end

      def raw_html
        body.raw_source
      end

      def self.variant_for(step, commune)
        if step == "lancement"
          nil
        elsif commune.inactive?
          "inactive"
        elsif commune.started? && !commune.all_objets_recensed?
          "started"
        elsif commune.started? && commune.all_objets_recensed?
          "to_complete"
        end
      end

      def self.i18n_name_for(step, commune)
        [step, variant_for(step, commune)].compact.join("_")
      end

      def self.possible_variants_for(step, commune)
        return %w[inactive] if %w[lancement relance1].include?(step)

        return %w[inactive to_complete] if commune.objets.count == 1

        VARIANTS
      end
    end
  end
end

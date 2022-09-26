# frozen_string_literal: true

module Campaigns
  class StepUpRecipientJob
    include Sidekiq::Job
    include ActiveSupport::Rescuable
    include Sidekiq::Throttled::Worker

    sidekiq_throttle(threshold: { limit: 10, period: 1.minute })
    sidekiq_options queue: "step_up_recipients", retry: 0

    attr_reader :to_step

    def perform(recipient_id, to_step)
      @recipient_id = recipient_id
      @to_step = to_step

      raise "Missing user with email for #{commune}" if user.nil?

      return false unless should_step_up?

      send_mail! unless should_skip_mail?
      recipient.update!(current_step: to_step)
      store_recipient_email! unless should_skip_mail?
      true
    end

    private

    def recipient
      @recipient ||= CampaignRecipient.includes(:commune, campaign: [:departement]).find(@recipient_id)
    end

    def campaign_mail
      @campaign_mail ||= Co::Campaigns::Mail.new(user:, commune:, campaign:, step: to_step)
    end

    def commune
      @commune ||= recipient.commune
    end

    def user
      @user ||= commune.users.where.not(email: nil).first
    end

    def campaign
      @campaign ||= recipient.campaign
    end

    def departement
      @departement ||= campaign.departement
    end

    def should_step_up?
      !recipient.opt_out? &&
        recipient.current_step == Campaign.previous_step_for(to_step) &&
        !commune.completed? # safeguard
    end

    def should_skip_mail?
      @should_skip_mail = recipient.should_skip_mail_for_step(to_step) if @should_skip_mail.nil?
      @should_skip_mail
    end

    def send_mail!
      smtp_response = campaign_mail.deliver_now!

      match_data = smtp_response.respond_to?("string") && smtp_response.string.match(/250 .* (<.*>)/)
      return if match_data.blank? && Rails.env.development?

      raise "Unexpected SMTP response : #{smtp_response.string}" unless match_data

      @sib_message_id = match_data[1]
    end

    def store_recipient_email!
      recipient.emails.create!(
        %i[step email_name subject raw_html headers]
          .to_h { [_1, campaign_mail.send(_1)] }
          .merge(sib_message_id: @sib_message_id)
      )
    end

    def record_invalid_handler(error)
      logger.error "invalid record #{error.record}, #{error.record.errors.full_messages.join}"
      raise error
    end
  end
end

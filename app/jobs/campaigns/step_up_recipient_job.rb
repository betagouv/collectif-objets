# frozen_string_literal: true

module Campaigns
  class StepUpRecipientJob
    include Sidekiq::Job
    include ActiveSupport::Rescuable

    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid_handler

    attr_reader :recipient, :to_step

    def perform(recipient_id, to_step)
      @recipient = CampaignRecipient.includes(:commune, campaign: [:departement]).find(recipient_id)
      @to_step = to_step
      return false unless should_send?

      raise "Missing user with email for #{commune}" if user.nil?

      send_mail!
      update_recipient!
      store_email!
      true
    end

    private

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

    def should_send?
      !recipient.opt_out? &&
        recipient.current_step == Campaign.previous_step_for(to_step) &&
        (to_step == "lancement" || commune.inactive?)
      # last one is a safeguard : never send reminders to active communes
    end

    def send_mail!
      smtp_response = email.deliver_now!

      match_data = smtp_response.string.match(/250 .* (<.*>)/)
      return if match_data.blank? && Rails.env.development?

      raise "Unexpected SMTP response : #{smtp_response.string}" unless match_data

      @sib_message_id = match_data[1]
    end

    def email
      @email ||= CampaignV1Mailer.with(user:, commune:, campaign:).send("#{to_step}_email")
    end

    def email_headers
      email.message.header.map { [_1.name, _1.value] }.to_h
    end

    def email_message
      email.message
    end

    def update_recipient!
      recipient.update!(current_step: to_step)
    end

    def store_email!
      recipient.emails.create!(
        step: to_step,
        sib_message_id: @sib_message_id,
        subject: email_message.subject,
        raw_html: email_message.body.raw_source,
        headers: email_headers
      )
    end

    def record_invalid_handler(error)
      logger.error "invalid record #{error.record}, #{error.record.errors.full_messages.join}"
      raise error
    end
  end
end

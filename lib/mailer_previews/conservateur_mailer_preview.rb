# frozen_string_literal: true

class ConservateurMailerPreview < ApplicationMailerPreview
  def message_received_email
    message = Message.from_commune.first
    conservateur = message.author

    ConservateurMailer.with(message:, conservateur:).message_received_email
  end
end

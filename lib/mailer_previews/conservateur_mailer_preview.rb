# frozen_string_literal: true

class ConservateurMailerPreview < ApplicationMailerPreview
  def message_received_email
    conservateur = build(:conservateur)
    commune = build(:commune, id: 999)
    user = build(:user, commune:)
    message = build(:message, commune:, author: user)

    ConservateurMailer.with(message:, conservateur:).message_received_email
  end
end

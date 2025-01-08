# frozen_string_literal: true

class RecenseurMailerPreview < ApplicationMailerPreview
  def session_code
    session_code = SessionCode.new(
      record: Recenseur.new(email: "recenseur@example.com", nom: "Nom recenseur").tap(&:readonly!),
      code: "234045"
    )
    RecenseurMailer.with(session_code:).session_code
  end
end

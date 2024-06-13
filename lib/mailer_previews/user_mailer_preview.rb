# frozen_string_literal: true

class UserMailerPreview < ApplicationMailerPreview
  def session_code_email
    session_code = SessionCode.new(
      user: User.new(email: "mairie@thoiry.fr").tap(&:readonly!),
      code: "234045"
    )
    UserMailer.with(session_code:).session_code_email
  end

  def commune_completed_email
    user = User.order(Arel.sql("RANDOM()")).first
    commune = Commune.order(Arel.sql("RANDOM()")).first
    UserMailer.with(user:, commune:).commune_completed_email
  end

  def commune_avec_objets_verts_email
    user = User.order(Arel.sql("RANDOM()")).first
    commune = Commune.order(Arel.sql("RANDOM()")).first
    UserMailer.with(user:, commune:).commune_avec_objets_verts_email
  end

  def dossier_accepted_email(dossier = nil, conservateur = nil)
    dossier = dossier&.clone || Dossier.find_by(status: "accepted")
    conservateur ||= dossier.conservateur
    UserMailer.with(dossier:, conservateur:).dossier_accepted_email
  end

  def dossier_auto_submitted
    user = User.order(Arel.sql("RANDOM()")).first
    commune = Commune.order(Arel.sql("RANDOM()")).first
    UserMailer.with(user:, commune:).dossier_auto_submitted_email
  end

  def message_received
    user = User.first
    message = Message.first

    UserMailer.with(message:, user:).message_received_email
  end
end

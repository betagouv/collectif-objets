# frozen_string_literal: true

class UserMailerPreview < ApplicationMailerPreview
  def validate_email
    user = User.new(email: "mairie@thoiry.fr", login_token: "a1r2b95")
    user.readonly!
    UserMailer.validate_email(user)
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
    dossier = dossier&.clone || Dossier.new(
      commune: Commune.new(
        nom: "Martigues",
        users: [
          User.new(
            email: "jean-lou@mairie-martigues.gov.fr"
          )
        ]
      ).tap(&:readonly!),
      status: "accepted",
      accepted_at: Time.zone.now - 2.days.ago,
      notes_conservateur: "Merci pour ce recensement complet",
      conservateur: Conservateur.new(
        first_name: "Léa",
        last_name: "Dupond",
        email: "lea-dupond@drac-de-la-france.gouv.fr"
      ).tap(&:readonly!)
    ).tap(&:readonly!)
    UserMailer.with(dossier:, conservateur:).dossier_accepted_email
  end

  def dossier_auto_submitted
    user = User.order(Arel.sql("RANDOM()")).first
    commune = Commune.order(Arel.sql("RANDOM()")).first
    UserMailer.with(user:, commune:).dossier_auto_submitted_email
  end

  def message_received
    user = build(:user, email: "jean.frank@mairie.fr")
    conservateur = build(:conservateur)
    message = build(
      :message,
      author: conservateur,
      origin: "web",
      text: "Bonjour, merci mais il manque des photos du calice de la chapelle"
    )

    UserMailer.with(message:, user:).message_received_email
  end
end

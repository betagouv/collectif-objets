# frozen_string_literal: true

class UserMailerPreview < ActionMailer::Preview
  def validate_email
    user = User.new(email: "mairie@thoiry.fr", login_token: "a1r2b95")
    user.readonly!
    UserMailer.validate_email(user)
  end

  def commune_completed_email
    user_id = User.order(Arel.sql("RANDOM()")).first.id
    commune_id = Commune.order(Arel.sql("RANDOM()")).first.id
    UserMailer.with(user_id:, commune_id:).commune_completed_email
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def dossier_accepted_email(dossier = nil)
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

    class << dossier
      def pdf
        Struct.new(:filename, :download).new(
          "rapport.pdf",
          File.read(Rails.root.join("public/pdf-en-cours-de-generation.pdf"))
        )
      end
    end

    UserMailer.with(dossier:).dossier_accepted_email
  end

  def dossier_rejected_email(dossier = nil)
    dossier = dossier&.clone || Dossier.new(
      commune: Commune.new(
        nom: "Martigues",
        users: [
          User.new(
            email: "jean-lou@mairie-martigues.gov.fr"
          )
        ]
      ).tap(&:readonly!),
      status: "rejected",
      notes_conservateur: "Veuillez rajouter des photos sur les objets",
      conservateur: Conservateur.new(
        first_name: "Léa",
        last_name: "Dupond",
        email: "lea-dupond@drac-de-la-france.gouv.fr"
      ).tap(&:readonly!)
    ).tap(&:readonly!)

    UserMailer.with(dossier:).dossier_rejected_email
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end

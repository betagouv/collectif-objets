# frozen_string_literal: true

class ConservateurMailerPreview < ActionMailer::Preview
  # rubocop:disable Metrics/MethodLength
  def commune_recompleted_email
    dossier =  Dossier.new(
      commune: Commune.new(
        id: 122,
        nom: "Martigues"
      ).tap(&:readonly!),
      status: "submitted",
      submitted_at: 2.days.ago,
      rejected_at: 1.month.ago,
      notes_conservateur: "Veuillez rajouter des photos et n'oubliez pas de préciser l'état. Merci",
      notes_commune: "J'ai pu reprendre les photos, j'espère que ça ira.",
      conservateur: Conservateur.new(
        first_name: "Léa",
        last_name: "Dupond",
        email: "lea-dupond@drac-de-la-france.gouv.fr"
      ).tap(&:readonly!)
    ).tap(&:readonly!)

    class << dossier
      def recensements
        Struct.new(:a, :b).new(1, 2) # will .count = 2
      end
    end

    ConservateurMailer.with(dossier:).commune_recompleted_email
  end
  # rubocop:enable Metrics/MethodLength
end

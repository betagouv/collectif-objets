class CommuneDecorator < Draper::Decorator
  delegate_all

  def display_name
    "#{nom} (#{code_insee})"
  end

  def status
    case super
    when nil
      ""
    when Commune::STATUS_ENROLLED
      "Commune Inscrite"
    when Commune::STATUS_STARTED
      "Recensement Démarré"
    when Commune::STATUS_COMPLETED
      "Recensement Terminé"
    end
  end

  def recensement_ratio
    "#{super}%" if super.present?
  end

  def first_user_email
    users.first&.email
  end
end

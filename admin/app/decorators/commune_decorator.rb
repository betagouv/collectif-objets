class CommuneDecorator < Draper::Decorator
  delegate_all

  def display_name
    "#{nom} (#{code_insee})"
  end

  def status
    aasm.human_state
  end

  def recensements_summary
    return nil if recensement_ratio.nil?

    html = "#{recensement_ratio}%"
    html += recensement_ratio == 0 || recensements_photos_present? ? "" : "<br /><span class='status_tag warning'>photos manquantes</span>"
    html.html_safe
  end

  def objets_count
    objets.count
  end

  def recensements_photos_present
    recensements.any? && recensements.missing_photos.empty?
  end

  def recensements_photos_present?; recensements_photos_present; end

  def first_user_email
    users.first&.email
  end
end

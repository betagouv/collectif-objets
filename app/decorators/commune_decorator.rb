# frozen_string_literal: true

class CommuneDecorator < Draper::Decorator
  delegate_all

  def display_name
    "#{nom} (#{code_insee})"
  end

  def status
    aasm.human_state
  end

  # rubocop:disable Rails/OutputSafety
  def recensements_summary
    return nil if recensement_ratio.nil?

    html = "#{recensement_ratio}%"
    html += if recensement_ratio.zero? ||
               recensements_photos_present?
              ""
            else
              "<br /><span class='status_tag warning'>photos manquantes</span>"
            end
    html.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  delegate :count, to: :objets, prefix: true

  def recensements_photos_present
    recensements.any? && recensements.missing_photos.empty?
  end

  def recensements_photos_present? = recensements_photos_present

  def first_user_email
    users.first&.email
  end

  def departement_with_name
    Co::Departements.number_and_name(departement)
  end
end

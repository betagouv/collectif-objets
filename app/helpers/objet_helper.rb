# frozen_string_literal: true

module ObjetHelper
  def objet_first_image_or_recensement_photo_url(objet)
    return objet.palissy_photos.first["url"] if objet.palissy_photos.any?

    if objet.current_recensement&.photos&.attached? && can_see_recensement_for(objet)
      return objet.current_recensement.photos.first.variant(:medium)
    end

    "images/illustrations/photo-manquante.png"
  end

  private

  def can_see_recensement_for(objet)
    current_user&.commune == objet.commune
  end
end

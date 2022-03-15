# frozen_string_literal: true

module ObjetHelper
  def objet_first_image_or_recensement_photo_url(objet)
    return objet.image_urls.first if objet.image_urls.any?

    if objet.commune == current_user&.commune && objet.current_recensement&.photos&.attached?
      return url_for(objet.current_recensement.photos.first)
    end

    "illustrations/photo-manquante.png"
  end
end

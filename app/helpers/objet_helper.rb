# frozen_string_literal: true

module ObjetHelper
  def objet_first_image_or_recensement_photo_url(objet)
    return objet.image_urls.first if objet.image_urls.any?

    if objet.current_recensement&.photos&.attached? && can_see_recensement_for(objet)
      return objet.current_recensement.photos.first.variant(:medium)
    end

    "images/illustrations/photo-manquante.png"
  end

  def edifice_nom(nom)
    return nom.upcase_first if nom.present?

    content_tag(:i, "Édifice non renseigné")
  end

  private

  def can_see_recensement_for(objet)
    current_user&.commune == objet.commune
  end
end

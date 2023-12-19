# frozen_string_literal: true

module GalerieHelper
  def galerie_objet(objet)
    turbo_frame = "galerie_objet_#{objet.id}"
    Galerie::FrameComponent.new(
      photos: objet.palissy_photos_presenters,
      title: t("objets.photos_count", count: objet.palissy_photos_presenters.count),
      turbo_frame:,
      display_actions: false,
      current_photo_id: params["#{turbo_frame}_photo_id"],
      path_without_query: request.path
    )
  end

  def galerie_recensement(recensement, display_actions: false)
    turbo_frame = "galerie_recensement_#{recensement.id}"
    Galerie::FrameComponent.new(
      photos: recensement.photos_presenters,
      title: t("recensement.photos.taken_count", count: recensement.photos_presenters.count),
      turbo_frame:,
      current_photo_id: params["#{turbo_frame}_photo_id"],
      path_without_query: request.path,
      display_actions:
    )
  end
end

# frozen_string_literal: true

module GalerieHelper
  def galerie_objet(objet)
    turbo_frame = "galerie_objet_#{objet.id}"
    galerie = Galerie::FrameComponent.new(
      photos: objet.palissy_photos_presenters,
      title: t("objets.photos_count", count: objet.palissy_photos_presenters.count),
      turbo_frame:,
      current_photo_id: params["#{turbo_frame}_photo_id"],
      path_without_query: request.path
    )
    galerie.actions = Galerie::ActionGroups::Base.new(galerie:)
    galerie
  end

  def galerie_recensement(recensement, actions_routes_scope: nil)
    turbo_frame = "galerie_recensement_#{recensement.id}"
    current_photo_id = params["#{turbo_frame}_photo_id"]
    galerie = Galerie::FrameComponent.new(
      photos: recensement.photos_presenters,
      title: t("recensement.photos.taken_count", count: recensement.photos_presenters.count),
      current_photo_id:,
      path_without_query: request.path,
      turbo_frame:
    )
    galerie.actions =
      if actions_routes_scope == :conservateurs
        Galerie::ActionGroups::ConservateurRecensement.new(recensement:, galerie:)
      else
        Galerie::ActionGroups::Base.new(galerie:)
      end
    galerie
  end
end

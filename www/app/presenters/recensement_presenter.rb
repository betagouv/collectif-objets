# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety

class RecensementPresenter
  include Rails.application.routes.url_helpers

  def initialize(recensement)
    @recensement = recensement
  end

  def badge(color)
    "
    <p class=\"fr-badge fr-badge--sm fr-badge--#{color}\">
      #{yield}
    </p>
    ".html_safe
  end

  def localisation
    case @recensement.localisation
    when Recensement::LOCALISATION_EDIFICE_INITIAL
      @recensement.objet.edifice_nom
    when Recensement::LOCALISATION_AUTRE_EDIFICE
      @recensement.edifice_nom
    when Recensement::LOCALISATION_ABSENT
      badge("warning") { "Introuvable" }
    end
  end

  def recensable
    if @recensement.recensable
      badge("success") { "Recensable" }
    else
      badge("warning") { "Impossible" }
    end
  end

  def etat_sanitaire_edifice
    case @recensement.etat_sanitaire_edifice
    when Recensement::ETAT_BON
      badge("success") { "Bon" }
    when Recensement::ETAT_CORRECT
      badge("info") { "Correct" }
    when Recensement::ETAT_MAUVAIS
      badge("new") { "Mauvais" }
    when Recensement::ETAT_PERIL
      badge("warning") { "En péril" }
    end
  end

  def etat_sanitaire
    case @recensement.etat_sanitaire
    when Recensement::ETAT_BON
      badge("success") { "Bon" }
    when Recensement::ETAT_CORRECT
      badge("info") { "Correct" }
    when Recensement::ETAT_MAUVAIS
      badge("new") { "Mauvais" }
    when Recensement::ETAT_PERIL
      badge("warning") { "En péril" }
    end
  end

  def securisation
    case @recensement.securisation
    when Recensement::SECURISATION_CORRECTE
      badge("success") { "En sécurité" }
    when Recensement::SECURISATION_MAUVAISE
      badge("warning") { "En danger" }
    end
  end

  def photos
    return badge("warning") { "Aucune photos" } if @recensement.photos.empty?

    photos_html = @recensement.photos.map do |photo|
      "<img src=\"#{url_for(photo)}\" />"
    end.join("\n")
    "
      <div>#{@recensement.photos.count} photo#{'s' if @recensement.photos.count > 1}</div>
      <div class=\"co-recensement-photos\">#{photos_html}</div>
    ".html_safe
  end
end

# rubocop:enable Rails/OutputSafety

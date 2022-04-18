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

  def text
    yield
  end

  def localisation
    case @recensement.localisation
    when Recensement::LOCALISATION_EDIFICE_INITIAL
      text { @recensement.objet.edifice_nom }
    when Recensement::LOCALISATION_AUTRE_EDIFICE
      text { @recensement.edifice_nom }
    when Recensement::LOCALISATION_ABSENT
      badge("warning") { "Introuvable" }
    end
  end

  def localisation_sentence
    case @recensement.localisation
    when Recensement::LOCALISATION_EDIFICE_INITIAL
      text { "L'objet est bien présent dans l'édifice #{@recensement.objet.edifice_nom}" }
    when Recensement::LOCALISATION_AUTRE_EDIFICE
      text { "L'objet a été déplacé dans un autre édifice" }
    when Recensement::LOCALISATION_ABSENT
      badge("warning") { "L'objet est introuvable" }
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
    generic_etat_sanitaire(@recensement.etat_sanitaire_edifice)
  end

  def etat_sanitaire
    generic_etat_sanitaire(@recensement.etat_sanitaire)
  end

  def analyse_etat_sanitaire_edifice
    generic_etat_sanitaire(@recensement.analyse_etat_sanitaire_edifice)
  end

  def analyse_etat_sanitaire
    generic_etat_sanitaire(@recensement.analyse_etat_sanitaire)
  end

  def securisation
    generic_securisation(@recensement.securisation)
  end

  def analyse_securisation
    generic_securisation(@recensement.analyse_securisation)
  end

  def photos_presence
    return missing_photos_badge if @recensement.missing_photos?

    badge("info") { I18n.t("recensement.photos.taken_count", count: @recensement.photos.count) }
  end

  def missing_photos_badge
    badge("warning") { I18n.t("recensement.photos.taken_count", count: 0) }
  end

  protected

  def generic_etat_sanitaire(value)
    case value
    when Recensement::ETAT_BON
      badge("success") { "Bon" }
    when Recensement::ETAT_MOYEN
      badge("info") { "Moyen" }
    when Recensement::ETAT_MAUVAIS
      badge("new") { "Mauvais" }
    when Recensement::ETAT_PERIL
      badge("warning") { "En péril" }
    end
  end

  def generic_securisation(value)
    case value
    when Recensement::SECURISATION_CORRECTE
      badge("success") { "En sécurité" }
    when Recensement::SECURISATION_MAUVAISE
      badge("warning") { "En danger" }
    end
  end
end

# rubocop:enable Rails/OutputSafety

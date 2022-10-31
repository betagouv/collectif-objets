# frozen_string_literal: true

# rubocop:disable Rails/OutputSafety

class RecensementPresenter
  include Rails.application.routes.url_helpers
  include RecensementHelper

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
    value = @recensement.etat_sanitaire_edifice
    return if value.blank?

    badge(etat_badge_color(value)) { I18n.t("recensement.etat_sanitaire_edifice_choices.#{value}") }
  end

  def etat_sanitaire
    value = @recensement.etat_sanitaire
    return if value.blank?

    badge(etat_badge_color(value)) { I18n.t("recensement.etat_sanitaire_choices.#{value}") }
  end

  def analyse_etat_sanitaire_edifice
    value = @recensement.analyse_etat_sanitaire_edifice
    return if value.blank?

    badge(etat_badge_color(value)) { I18n.t("recensement.etat_sanitaire_edifice_choices.#{value}") }
  end

  def analyse_etat_sanitaire
    value = @recensement.analyse_etat_sanitaire
    return if value.blank?

    badge(etat_badge_color(value)) { I18n.t("recensement.etat_sanitaire_choices.#{value}") }
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

  def generic_securisation(value)
    case value
    when Recensement::SECURISATION_CORRECTE
      badge("success") { I18n.t("recensement.securisation_badges.correcte") }
    when Recensement::SECURISATION_MAUVAISE
      badge("warning") { I18n.t("recensement.securisation_badges.mauvaise") }
    end
  end
end

# rubocop:enable Rails/OutputSafety

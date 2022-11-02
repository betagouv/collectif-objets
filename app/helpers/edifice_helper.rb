# frozen_string_literal: true

module EdificeHelper
  def edifice_nom(edifice)
    return edifice.nom.upcase_first if edifice.nom.present?

    content_tag(:i, "Édifice non renseigné")
  end
end

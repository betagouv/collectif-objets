# frozen_string_literal: true

module EdificeHelper
  def texte_nombre_objets_protégés(edifice)
    nombre_objets_protégés = edifice.objets.protégés.count
    case nombre_objets_protégés
    when 0
      "Aucun objet protégé"
    when 1
      "1 objet protégé"
    else
      "#{nombre_objets_protégés} objets protégés"
    end
  end
end

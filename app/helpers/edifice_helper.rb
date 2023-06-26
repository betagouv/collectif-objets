# frozen_string_literal: true

module EdificeHelper
  def nombre_objets_classés_et_inscrits(edifice)
    if edifice.objets.classés.count > 1
      "#{edifice.objets.classés.count} objets classés"
    else
      "1 objet classé"
    end
  end
end

# frozen_string_literal: true

module EdificeHelper
  def nombre_objets_classés_et_inscrits(edifice)
    nombre_objets_classés = case edifice.objets.classés.count
                            when 0
                              ""
                            when 1
                              "1 objet classé"
                            else
                              "#{edifice.objets.classés.count} objets classés"
                            end

    nombre_objets_inscrits = case edifice.objets.inscrits.count
                             when 0
                               ""
                             when 1
                               "1 objet inscrit"
                             else
                               "#{edifice.objets.inscrits.count} objets inscrits"
                             end

    liasion = nombre_objets_classés.present? && nombre_objets_inscrits.present? ? " et " : ""

    nombre_objets_classés + liasion + nombre_objets_inscrits
  end
end

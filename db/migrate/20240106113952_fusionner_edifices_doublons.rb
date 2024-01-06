class FusionnerEdificesDoublons < ActiveRecord::Migration[7.1]
  def up
    code_insee_and_slugs = get_problematic_code_insee_and_slugs
    total_edifices_count = code_insee_and_slugs.sum { Edifice.where(_1).count }
    puts "#{total_edifices_count} edifices sont invalides et partagent le même code_insee et slug"

    code_insee_and_slugs.each { corriger_doublons(**_1) }
    count_after = get_problematic_code_insee_and_slugs.sum { Edifice.where(_1).count }
    raise "il reste #{count_after} edifices invalides" if count_after.positive?
  end

  private

  def get_problematic_code_insee_and_slugs
    sql = "SELECT code_insee, slug FROM edifices GROUP BY code_insee, slug HAVING COUNT(*) >= 2"
    return ActiveRecord::Base.connection.execute(sql).map { _1.to_h.symbolize_keys }
  end

  def corriger_doublons(code_insee:, slug:)
    edifices = Edifice.where(code_insee:, slug:)
    raise "il y a #{edifices.count} edifices pour #{code_insee}-#{slug}" if edifices.count != 2

    avec_objets, sans_objets = edifices.partition { _1.objets.any? }
    if sans_objets.any?
      puts "Pour #{code_insee}-#{slug} il y a (au moins) un édifice sans objet, on le supprime"
      fusionner_edifices(a_supprimer: sans_objets.first, a_garder: avec_objets.first || sans_objets.second)
      return
    end

    avec_ref, sans_ref = edifices.partition { _1.merimee_REF.present? }
    if avec_ref.count == 1 && sans_ref.count == 1
      puts "Pour #{code_insee}-#{slug} il y a un édifice avec ref (#{avec_ref.first.id}) et un autre sans (#{sans_ref.first.id}), on supprime ce dernier"
      fusionner_edifices(a_garder: avec_ref.first, a_supprimer: sans_ref.first)
      return
    end

    raise "impossible de décider quel édifice garder pour #{edifices.map(&:attributes)}"
  end

  def fusionner_edifices(a_garder:, a_supprimer:)
    raise unless a_garder.code_insee == a_supprimer.code_insee

    a_supprimer.objets.update_all(edifice_id: a_garder.id)
    a_supprimer.destroy!
  end
end

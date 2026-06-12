# frozen_string_literal: true

class Stats
  def cache_key = @cache_key ||= Recensement.maximum(:updated_at)

  # Campagnes
  def total_départements_actifs = départements_actifs.count
  def total_campagnes_par_département = Departement.sorted.include_active_campaigns_count
  def total_campagnes_actives = Campaign.active.count

  # Objets
  def total_objets_protégés = Objet.protégés.count
  def total_objets_protégés_dans_départements_actifs = objets_protégés_dans_départements_actifs.count
  def total_objets_recensés = Objet.recensés.dans_départements_actifs.ids.length
  def total_objets_prioritaires_pris_en_charge = Objet.prioritaires.analysés.dans_départements_actifs.length
  def ratio_objets_recensés = percent(total_objets_recensés, of: total_objets_protégés_dans_départements_actifs)

  def ratio_objets_prioritaires_pris_en_charge
    percent(total_objets_prioritaires_pris_en_charge, of: Objet.prioritaires.count)
  end

  # Communes
  def total_communes_participantes = Commune.participantes.count
  def total_communes_contactées = Commune.contactées.count
  def total_communes_dans_départements_actifs = Commune.dans_départements_actifs.count
  def ratio_communes_contactées = percent(total_communes_contactées, of: total_communes_dans_départements_actifs)

  # Recensements
  def total_recensements_préoccupants = Recensement.acceptés.préoccupants.count
  def total_recensements_acceptés = Recensement.acceptés.count
  def ratio_recensements_préoccupants = percent(total_recensements_préoccupants, of: total_recensements_acceptés)
  def ratio_recensements_fiables = percent(Recensement.acceptés.sans_changement.count, of: Recensement.acceptés.count)

  protected

  # Reused scopes
  def départements_actifs = Departement.active.distinct
  def objets_protégés_dans_départements_actifs = Objet.protégés.dans_départements_actifs

  private

  def percent(amount, of:)
    return 0 if of.zero?

    (amount.to_f / of * 100).round
  end
end

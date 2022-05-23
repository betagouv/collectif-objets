SEED = 1
GEN = Random.new(SEED)

raise unless ["staging", "development"].include?(Rails.configuration.x.environment_specific_name)

def rand_item(arr)
  return nil if arr.empty?
  return arr[0] if arr.count == 1
  arr[GEN.rand(arr.count - 1)]
end

def seed_commune(commune)
  puts "  filling recensements for #{commune.code_insee} #{commune.nom}..."
  dossier = Dossier.new(
    commune:,
    status: "submitted",
    submitted_at: Time.zone.now,
    notes_commune: "Merci pour vos retours"
  )
  dossier.save
  raise dossier.errors.full_messages.join unless dossier.valid?
  commune.update!(dossier:, status: Commune::STATE_COMPLETED, completed_at: Time.zone.now)
  commune.objets.each { seed_objet(_1, dossier, commune) }
end

def seed_objet(objet, dossier, commune)
  puts "    creating recensement for #{objet.ref_pop} #{objet.nom}"
  recensement = Recensement.new(
    objet:,
    dossier:,
    # localisation: rand_item(Recensement::LOCALISATIONS),
    localisation: Recensement::LOCALISATION_EDIFICE_INITIAL,
    recensable: true,
    etat_sanitaire: rand_item(Recensement::ETATS),
    etat_sanitaire_edifice: rand_item(Recensement::ETATS),
    securisation: rand_item(Recensement::SECURISATIONS),
    notes: rand_item([
      nil,
      "L'objet présente des petites fissures sur l'arrière."
    ]),
    user: commune.users.first,
    skip_photos: true,
    confirmation: true
  )
  recensement.save
  raise recensement.errors.full_messages.join unless recensement.valid?
  rand_item([
    [],
    ["statue_1"],
    ["autel_1", "autel_2"],
    ["autel_1"],
    ["promontoire"],
    ["buste_1"],
    ["tableau_1", "tableau_2"],
    ["tableau_1"]
  ]).each do |photoname|
    raise unless recensement.photos.attach(
      io: File.open(Rails.root.join("db/seeds/recensement_photos/#{photoname}.jpg")),
      filename: "#{photoname}.jpg"
    )
  end
end

Commune.select(:departement).distinct.pluck(:departement).compact.each do |departement|
  puts "departement #{departement}..."
  commune_ids = Commune.where(departement:).where(dossier_id: nil).joins(:users).pluck(:id)
  next if commune_ids.empty?

  10.times do
    commune_id = rand_item(commune_ids)
    commune = Commune.includes(:users).joins(:users).find(commune_id)
    raise if commune.recensements.any?
    raise if commune.users.empty?
    seed_commune(commune)
  end
  puts "----\n\n"
end

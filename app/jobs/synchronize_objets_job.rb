# frozen_string_literal: true

class SynchronizeObjetsJob
  include Sidekiq::Job

  API_URL = "https://collectif-objets-datasette.fly.dev/collectif-objets/palissy.json"
  BASE_PARAMS = {
    _size: "1000",
    _sort: "REF",
    _shape: "objects",
    _nofacet: "1",
    _col: %w[REF DENO CATE COM INSEE DPT SCLE DENQ DOSS EDIF EMPL TICO MEMOIRE_URLS],
    DOSS: "dossier individuel",
    PROT__not: "déclassé",
    STAT__not: ["propriété de l'Etat (?)", "propriété de l'Etat"]
  }.freeze
  MEMOIRE_PHOTOS_BASE_URL = "https://s3.eu-west-3.amazonaws.com/pop-phototeque"

  def perform(departement = nil)
    if departement.present?
      synchronize_departement(departement)
    else
      Departement.all.each { synchronize_departement(_1.code) }
    end
  end

  private

  def synchronize_departement(departement)
    logger.info "before: #{Objet.where(departement:).count} objets in #{departement}"

    initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS.merge(DPT: departement))}"
    api_query(initial_url, initial: true)

    logger.info "after: #{Objet.where(departement:).count} objets in #{departement}\n"
  end

  def api_query(url, initial: false)
    parsed = fetch_and_parse(url)
    logger.info "-- query : #{parsed['query']}" if initial
    logger.info "-- total rows filtered: #{parsed['filtered_table_rows_count']}" if initial

    parsed["rows"].each { synchronize_objet(_1) }

    trigger_next_query(parsed)
  end

  def fetch_and_parse(url)
    logger.info "fetching #{url} ..."
    res = Net::HTTP.get_response(URI.parse(url))
    raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

    parsed = JSON.parse(res.body)
    logger.debug "request took #{parsed['query_ms'].round} ms"
    parsed
  end

  def synchronize_objet(raw_objet)
    objet = build_objet_from_raw(raw_objet)
    return if should_skip_objet?(objet)

    logger.info "saving new objet #{raw_objet['REF']} ! #{objet.attributes.compact}" if objet.new_record?
    objet.save!
  end

  def build_objet_from_raw(raw_objet)
    objet = Objet.where(palissy_REF: raw_objet["REF"]).first_or_initialize
    new_attributes = %w[DENO CATE COM INSEE DPT SCLE DENQ DOSS EDIF EMPL TICO].to_h do |pop_column|
      ["palissy_#{pop_column}", raw_objet[pop_column]]
    end
    new_attributes["image_urls"] = objet_overrides_by_ref[raw_objet["REF"]]&.image_urls \
      || raw_objet["MEMOIRE_URLS"]&.split(";")&.map { "#{MEMOIRE_PHOTOS_BASE_URL}/#{_1}" } || []
    objet.assign_attributes(new_attributes)
    objet
  end

  def trigger_next_query(parsed)
    return unless parsed["next_url"]

    sleep(0.5)
    api_query(parsed["next_url"])
  end

  def should_skip_objet?(objet)
    return false if objet.persisted?

    return true if objet.palissy_COM == "Sablé-sur-Sarthe" && objet.palissy_EDIF == "château"
  end

  def objet_overrides_by_ref
    @objet_overrides_by_ref ||= ObjetOverride.all.map { [_1.palissy_REF, _1] }.to_h
  end
end

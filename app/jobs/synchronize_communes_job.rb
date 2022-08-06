# frozen_string_literal: true

class SynchronizeCommunesJob
  include Sidekiq::Job

  API_URL = "https://collectif-objets-datasette.fly.dev/collectif-objets/mairies.json"
  BASE_PARAMS = {
    _size: "1000",
    _sort: "code_insee",
    _shape: "objects",
    _nofacet: "1"
  }.freeze

  def perform(departement = nil)
    if departement.present?
      synchronize_departement(departement)
    else
      Co::Departements.numbers.each { synchronize_departement(_1) }
    end
  end

  private

  def synchronize_departement(departement)
    logger.info "before: #{Commune.where(departement:).count} communes in #{departement}"

    initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS.merge(code_insee__startswith: departement))}"
    api_query(initial_url, initial: true)

    logger.info "after: #{Commune.where(departement:).count} communes in #{departement}\n"
  end

  def api_query(url, initial: false)
    parsed = fetch_and_parse(url)
    logger.info "-- query : #{parsed['query']}" if initial
    logger.info "-- total rows filtered: #{parsed['filtered_table_rows_count']}" if initial

    parsed["rows"].each { create_new_commune(_1) }

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

  def create_new_commune(raw_mairie)
    return if should_skip_commune?(raw_mairie)

    logger.info "upserting commune #{raw_mairie}"
    commune = upsert_commune(raw_mairie)
    unless commune.persisted?
      logger.info "error when upserting commune : #{commune.errors.full_messages.join} (#{raw_mairie})"
      return
    end

    create_user(raw_mairie, commune)
  end

  def upsert_commune(raw_mairie)
    commune = Commune.find_or_initialize_by(code_insee: raw_mairie["code_insee"])

    commune.assign_attributes(
      **raw_mairie.slice("nom", "departement", "latitude", "longitude"),
      phone_number: raw_mairie["telephone"]
    )
    commune.tap(&:save)
  end

  def create_user(raw_mairie, commune)
    return if raw_mairie["email"].blank? || commune.users.any?

    attributes = {
      email: raw_mairie["email"],
      magic_token: SecureRandom.hex(10),
      role: User::ROLE_MAIRIE,
      commune_id: commune.id
    }
    user = User.new(attributes).tap(&:save)
    logger.info "error when saving user : #{user.errors.full_messages.join} (#{attributes})" if user.errors.any?
  end

  def trigger_next_query(parsed)
    return unless parsed["next_url"]

    sleep(0.5)
    api_query(parsed["next_url"])
  end

  def should_skip_commune?(raw_mairie)
    Objet.where(commune_code_insee: raw_mairie["code_insee"]).empty? # we only create communes when there are objets
  end
end

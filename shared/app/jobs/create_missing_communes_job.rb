# frozen_string_literal: true

class CreateMissingCommunesJob
  include Sidekiq::Job

  API_URL = "https://collectif-objets-datasette-g67bg74vua-uc.a.run.app/collectif-objets/mairies.json"
  BASE_PARAMS = {
    _size: "1000",
    _sort: "code_insee",
    _shape: "objects",
    _nofacet: "1"
  }.freeze

  def perform(departement)
    @departement = departement
    logger.info "before: #{Commune.where(departement:).count} communes in #{departement}"

    initial_url = "#{API_URL}?#{URI.encode_www_form(BASE_PARAMS.merge(code_insee__startswith: @departement))}"
    api_query(initial_url, initial: true)

    logger.info "after: #{Commune.where(departement:).count} communes in #{departement}"
  end

  private

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

  def create_new_commune(raw_commune)
    return if should_skip_commune?(raw_commune)

    logger.info "saving new commune #{raw_commune}"
    commune = build_commune(raw_commune)
    return if commune.save

    logger.info "error when saving commune : #{commune.errors.full_messages.join} (#{raw_commune})"
  end

  # rubocop:disable Metrics/MethodLength
  def build_commune(raw_commune)
    users_attributes = [
      email: raw_commune["email"],
      magic_token: SecureRandom.hex(10),
      role: User::ROLE_MAIRIE
    ]
    Commune.new(
      nom: raw_commune["nom"],
      code_insee: raw_commune["code_insee"],
      departement: @departement,
      phone_number: raw_commune["telephone"],
      users_attributes: raw_commune["email"].present? ? users_attributes : []
    )
  end
  # rubocop:enable Metrics/MethodLength

  def trigger_next_query(parsed)
    return unless parsed["next_url"]

    sleep(0.5)
    api_query(parsed["next_url"])
  end

  def should_skip_commune?(raw_commune)
    Commune.where(code_insee: raw_commune["code_insee"]).any? || # we don't override existing communes at all for now
      Objet.where(commune_code_insee: raw_commune["code_insee"]).empty? # we only create communes when there are objets
  end
end

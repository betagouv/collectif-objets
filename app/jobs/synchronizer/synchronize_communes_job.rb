# frozen_string_literal: true

module Synchronizer
  class SynchronizeCommunesJob
    include Sidekiq::Job

    API_URL = "https://api-lannuaire.service-public.fr/api/explore/v2.1/catalog/datasets/api-lannuaire-administration/records"
    ITEMS_PER_PAGE = 100
    BASE_WHERE_CLAUSES = [
      %|startswith(pivot, '[{"type_service_local": "mairie",')|,
      "NOT startswith(nom, 'Mairie déléguée')"
    ].freeze
    BASE_PARAMS = {
      order_by: "code_insee_commune",
      limit: ITEMS_PER_PAGE,
      select: %w[code_insee_commune nom telephone]
    }.freeze

    def perform(departement = nil)
      if departement.present?
        synchronize_departement(departement)
      else
        Departement.find_each { synchronize_departement(_1.code) }
      end
    end

    private

    def synchronize_departement(departement)
      logger.info "before: #{Commune.where(departement:).count} communes in #{departement}"

      api_query(where_clauses: [%{startswith(code_insee_commune, "#{departement}")}], offset: 0)

      logger.info "after: #{Commune.where(departement:).count} communes in #{departement}\n"
    end

    def api_query(where_clauses:, offset:)
      parsed = fetch_and_parse(where_clauses)
      logger.info "-- total rows filtered: #{parsed['total_count']}" if offset.zero?

      parsed["results"].each { create_new_commune(_1) }

      trigger_next_query(where_clauses:, total_count: parsed["total_count"], offset:)
    end

    def fetch_and_parse(where_clauses)
      params = BASE_PARAMS.merge(where: (BASE_WHERE_CLAUSES + where_clauses).join(" AND "))
      url = "#{API_URL}?#{URI.encode_www_form(params)}"

      logger.info "fetching #{url} ..."
      res = Net::HTTP.get_response(URI.parse(url))
      raise "received #{res.code} on #{url}" unless res.code.starts_with?("2")

      parsed = JSON.parse(res.body)
      parsed["results"] = parsed["results"].map { parse_result(_1) }
      # display readable parsed
      parsed["results"].each { logger.info _1 }
      parsed
    end

    def parse_result(result)
      {
        code_insee: result["code_insee_commune"],
        departement_code: parse_departement(result["code_insee_commune"]),
        nom: result["nom"].gsub(/^Mairie - ?/, ""),
        phone_number: result["telephone"].present? && JSON.parse(result["telephone"]).first["valeur"],
        email: result["adresse_courriel"]
      }
    end

    def parse_departement(code_insee)
      code_insee.starts_with?("97") ? code_insee[0..2] : code_insee[0..1]
    end

    def create_new_commune(raw_mairie)
      return if should_skip_commune?(raw_mairie[:code_insee])

      logger.info "upserting commune #{raw_mairie}"
      commune = upsert_commune(**raw_mairie)
      unless commune.persisted?
        logger.info "error when upserting commune : #{commune.errors.full_messages.join} (#{raw_mairie})"
        return
      end

      create_user(raw_mairie[:email], commune)
    end

    def upsert_commune(code_insee:, departement_code:, nom:, phone_number:, **)
      commune = Commune.find_or_initialize_by(code_insee:)
      commune.assign_attributes(departement_code:, nom:, phone_number:)
      if commune.changed?
        logger.info "saving changes to #{commune.new_record? ? 'new' : 'existing'} commune #{commune.changes}"
        commune.save!
      end
      commune
    end

    def create_user(email, commune)
      return if email.blank? || commune.users.any?

      attributes = {
        email:,
        magic_token: SecureRandom.hex(10),
        role: User::ROLE_MAIRIE,
        commune_id: commune.id
      }
      user = User.new(attributes).tap(&:save)
      logger.info "error when saving user : #{user.errors.full_messages.join} (#{attributes})" if user.errors.any?
    end

    def trigger_next_query(where_clauses:, total_count:, offset:)
      next_offset = offset + ITEMS_PER_PAGE
      return if total_count.zero? || next_offset >= total_count

      sleep(0.5)
      api_query(where_clauses:, offset: next_offset)
    end

    def should_skip_commune?(code_insee)
      Objet.where(commune_code_insee: code_insee).empty? # we only create communes when there are objets
    end
  end
end

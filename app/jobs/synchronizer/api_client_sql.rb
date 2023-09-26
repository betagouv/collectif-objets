# frozen_string_literal: true

module Synchronizer
  class ApiClientSql
    include ApiClientConcern

    API_PATH = "data.json"

    QUERY = Struct.new(:table, :select_cols, :join, :where, :group, keyword_init: true)

    def self.objets(logger:, limit:, code_insee: nil)
      new(
        QUERY.new(
          table: "palissy",
          select_cols: "
            palissy.rowid,
            REF, DENO, CATE, SCLE, DENQ, COM, INSEE, DPT, DOSS, EDIF, EMPL, TICO, DPRO, PROT,
            group_concat(ptmerimee.REF_MERIMEE) as REFS_MERIMEE
          ",
          join: <<~SQL.squish,
            left join palissy_to_merimee ptmerimee on ptmerimee.REF_PALISSY = palissy.REF
          SQL
          where: objets_where_clause(code_insee:),
          group: "group by palissy.REF"
        ), logger:, limit:
      )
    end

    def self.objets_where_clause(code_insee: nil)
      # Le code SQL ci-dessous contient des règles d'import. Il devrait plutôt se trouver dans le model Objet
      sql = <<~SQL.squish
        WHERE "DOSS" IN ('dossier individuel', 'dossier avec sous-dossier', 'individuel', 'dossier indiviuel', 'dossier avec sous-dossiers')
        and ("MANQUANT" is NULL OR "MANQUANT" NOT IN ('manquant', 'volé'))
        and ("PROT" IS NULL OR "PROT" != 'déclassé')
        and "propriété de l'Etat" not in (select value from json_each([palissy].[STAT]))
        and "propriété de l'Etat (?)" not in (select value from json_each([palissy].[STAT]))
        and "TICO" != 'Traitement en cours'
      SQL
      sql += %(and [palissy].[INSEE] = '#{code_insee}') if code_insee
      sql
    end

    def self.edifices(logger:, limit:)
      new(
        QUERY.new(
          table: "merimee",
          select_cols: "REF, INSEE, TICO, PRODUCTEUR",
          join: "INNER JOIN palissy_to_merimee ptm ON merimee.REF = ptm.REF_MERIMEE",
          group: "group by REF, INSEE, TICO, PRODUCTEUR"
        ), logger:, limit:
      )
    end

    def initialize(query, logger:, limit:)
      @query = query
      @logger = logger
      @limit = limit
    end

    def iterate_batches
      create_progress_bar(total_rows)
      @request_number = 1
      api_query { yield _1 }
    end

    def iterate
      iterate_batches { |batch| batch.each { yield _1 } }
    end

    private

    def total_rows
      sql = "select count(*) as c from (select REF from #{@query.table} #{@query.join} #{@query.where} #{@query.group})"
      @logger.info sql
      fetch_and_parse(API_PATH, { sql: })["rows"][0][0]
    end

    def api_query(after_ref: nil)
      sql = get_sql_query(after_ref:)
      @logger.debug sql
      parsed = fetch_and_parse(API_PATH, sql:)
      parsed["rows"] = parsed["rows"].map { parsed["columns"].zip(_1).to_h }
      yield parsed["rows"]
      increment_progress_bar parsed["rows"].count
      trigger_next_query(parsed) { yield _1 }
    end

    def get_sql_query(after_ref: nil)
      offset_clause = after_ref ? "AND #{@query.table}.REF > '#{after_ref}'" : ""
      <<~SQL.squish
        SELECT #{@query.select_cols}
        FROM #{@query.table}
        #{@query.join}
        #{@query.where}
        #{offset_clause}
        #{@query.group}
        ORDER BY #{@query.table}.REF
        LIMIT #{PER_PAGE}
      SQL
    end

    def trigger_next_query(parsed)
      return if parsed["rows"].count < PER_PAGE || limit_reached?

      sleep(0.5)
      @request_number += 1
      api_query(after_ref: parsed["rows"][-1]["REF"]) { yield _1 }
    end
  end
end

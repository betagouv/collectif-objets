# frozen_string_literal: true

module Synchronizer
  class ApiClientSql
    include ApiClientConcern

    API_PATH = "data.json"

    QUERY = Struct.new(:table_name, :select_from_join, :where, :group, keyword_init: true)
    OBJETS_QUERY = QUERY.new(
      table_name: "palissy",
      select_from_join: <<~SQL.squish,
        select
          palissy.rowid,
          REF, DENO, CATE, SCLE, DENQ, COM, INSEE, DPT, DOSS, EDIF, EMPL, TICO,
          group_concat(ptmerimee.REF_MERIMEE) as REFS_MERIMEE
        from palissy
        left join palissy_to_merimee ptmerimee on ptmerimee.REF_PALISSY = palissy.REF
      SQL
      where: <<~SQL.squish,
        WHERE "DOSS" = 'dossier individuel'
        and ("MANQUANT" is NULL OR "MANQUANT" NOT IN ('manquant', 'volé'))
        and ("PROT" IS NULL OR "PROT" != 'déclassé')
        and "propriété de l'Etat" not in (select value from json_each([palissy].[STAT]))
        and "propriété de l'Etat (?)" not in (select value from json_each([palissy].[STAT]))
      SQL
      group: "group by palissy.REF"
    )

    def self.objets(logger:, limit:)
      new(OBJETS_QUERY, logger:, limit:)
    end

    def initialize(query, logger:, limit:)
      @query = query
      @logger = logger
      @limit = limit
    end

    def iterate
      create_progress_bar(total_rows)
      @request_number = 1
      api_query { yield _1 }
    end

    private

    def total_rows
      sql = "select count(*) as c from #{@query.table_name} #{@query.where}"
      fetch_and_parse(API_PATH, { sql: })["rows"][0][0]
    end

    def api_query(previous_rowid: nil)
      parsed = fetch_and_parse(API_PATH, sql: get_sql_query(previous_rowid:))
      parsed["rows"] = parsed["rows"].map { parsed["columns"].zip(_1).to_h }
      yield parsed["rows"]
      increment_progress_bar parsed["rows"].count
      trigger_next_query(parsed) { yield _1 }
    end

    def get_sql_query(previous_rowid: nil)
      offset_clause = previous_rowid ? "AND #{@query.table_name}.rowid > #{previous_rowid}" : ""
      <<~SQL.squish
        #{@query.select_from_join}
        #{@query.where}
        #{offset_clause}
        #{@query.group}
        ORDER BY palissy.rowid
        LIMIT #{PER_PAGE}
      SQL
    end

    def trigger_next_query(parsed)
      return if parsed["rows"].count < PER_PAGE || limit_reached?

      sleep(0.5)
      @request_number += 1
      api_query(previous_rowid: parsed["rows"][-1]["rowid"]) { yield _1 }
    end
  end
end

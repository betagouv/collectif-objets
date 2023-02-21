# frozen_string_literal: true

module Synchronizer
  class ApiClientSql
    include ApiClientConcern

    API_PATH = "data.json"

    QUERY = Struct.new(:select_clause, :from, :table_name, :join, :where, :group_by_clause, :order_by,
                       keyword_init: true)
    OBJETS_QUERY_SQL = <<~SQL.squish.freeze
      SELECT palissy.rowid,
       REF, DENO, CATE, SCLE, DENQ, COM, INSEE, DPT, DOSS, EDIF, EMPL, TICO,
       group_concat(ptmerimee.REF_MERIMEE) as REFS_MERIMEE
      FROM palissy
      LEFT JOIN palissy_to_merimee ptmerimee on ptmerimee.REF_PALISSY = palissy.REF
      WHERE "DOSS" IN ('dossier individuel', 'dossier avec sous-dossier', 'individuel', 'dossier indiviuel', 'dossier avec sous-dossiers')
        AND ("MANQUANT" is NULL OR "MANQUANT" NOT IN ('manquant', 'volé'))
        AND ("PROT" IS NULL OR "PROT" != 'déclassé')
        AND "propriété de l'Etat" NOT IN (SELECT VALUE FROM json_each([palissy].[STAT]))
        AND "propriété de l'Etat (?)" NOT IN (SELECT VALUE FROM json_each([palissy].[STAT]))
        -- TODO: inject offset clause
      GROUP BY palissy.REF
      ORDER BY palissy.REF
      -- TODO: inject LIMIT clause
    SQL
    # EDIFICES_QUERY = QUERY.new(
    #   table: "merimee",
    #   select_cols: "REF, INSEE, TICO, PRODUCTEUR",
    #   join: "INNER JOIN palissy_to_merimee ptm ON merimee.REF = ptm.REF_MERIMEE",
    #   group: "group by REF, INSEE, TICO, PRODUCTEUR"
    # )
    #
    SQL_QUERY_REGEX = /^
      (?<select_clause>SELECT\s.*)
      \s?(?<from>FROM\s(?<table_name>\w+))
      \s*(?<join>LEFT\sJOIN\s.*)?
      \s?(?<where>WHERE\s.*)
      \s?(?<group_by_clause>GROUP\sBY\s.*)?
      \s?(?<order_by>ORDER\sBY\s.*)$
    /mx

    def self.objets(logger:, limit: nil)
      new(OBJETS_QUERY_SQL, logger:, limit:)
    end

    # def self.edifices(logger:, limit:)
    #   new(EDIFICES_QUERY, logger:, limit:)
    # end

    def initialize(query_sql, logger:, limit: nil)
      @query_sql = query_sql
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

    def total_rows
      sql = "select count(*) as c from " \
            "(select REF from #{query.table_name} #{query.join} #{query.where} #{query.group_by_clause})"
      @logger.info sql
      fetch_and_parse(API_PATH, { sql: })["rows"][0][0]
    end

    private

    def parse_sql_query(query)
      query.match(SQL_QUERY_REGEX)
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
      offset_clause = after_ref ? "AND #{query.table_name}.REF > '#{after_ref}'" : ""
      <<~SQL.squish
        #{query.select_clause}
        #{query.from}
        #{query.join}
        #{query.where}
        #{offset_clause}
        #{query.group_by_clause}
        #{query.order_by}
        LIMIT #{PER_PAGE}
      SQL
    end

    def query
      @query ||= QUERY.new(**parse_sql_query(@query_sql).named_captures.symbolize_keys)
    end

    def trigger_next_query(parsed)
      return if parsed["rows"].count < PER_PAGE || limit_reached?

      sleep(0.5)
      @request_number += 1
      api_query(after_ref: parsed["rows"][-1]["REF"]) { yield _1 }
    end
  end
end

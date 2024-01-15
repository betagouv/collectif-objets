# frozen_string_literal: true

module Synchronizer
  module Edifices
    class Row
      def initialize(row)
        @row = row
      end

      def synchronize
        Edifice.where(merimee_REF: @row["REF"]).update_all(attributes)
      end

      def attributes
        {
          nom: @row["TICO"],
          merimee_PRODUCTEUR: @row["PRODUCTEUR"],
          code_insee: @row["INSEE"],
          slug: Edifice.slug_for(@row["TICO"])
        }
      end
    end
  end
end

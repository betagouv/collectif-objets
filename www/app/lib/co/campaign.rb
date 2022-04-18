# frozen_string_literal: true

module Co
  class Campaign
    DEADLINES = {
      "51" => Date.new(2022, 4, 15),
      "65" => Date.new(2022, 5, 15),
      "72" => Date.new(2022, 5, 28)
    }.freeze

    def self.for_departement(departement)
      return nil if DEADLINES.keys.exclude?(departement)

      new(departement)
    end

    def initialize(departement)
      @departement = departement
    end

    def begin
      DEADLINES[@departement] - 2.months
    end

    def end
      DEADLINES[@departement]
    end
  end
end

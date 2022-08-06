# frozen_string_literal: true

module Co
  class Departement
    attr_accessor :number, :name, :communes_count

    def initialize(number:, name:, communes_count: nil)
      @number = number
      @name = name
      @communes_count = communes_count
    end

    def self.from_number(number)
      new(
        number:,
        name: Co::Departements::NAMES[number],
        communes_count: Commune.where(departement: number).count
      )
    end

    def to_s
      [number, name].join(" - ")
    end
  end
end

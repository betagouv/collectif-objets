# frozen_string_literal: true

module Co
  class Departement
    attr_accessor :number, :name, :communes_count, :objets_count

    def initialize(number:, name:, communes_count: nil, objets_count: nil)
      @number = number
      @name = name
      @communes_count = communes_count
      @objets_count = objets_count
    end

    def self.from_number(number)
      new(
        number:,
        name: Co::Departements::NAMES[number],
        communes_count: Commune.where(departement: number).count,
        objets_count: Objet.where(palissy_DPT: number).count
      )
    end

    def to_s
      [number, name].join(" - ")
    end

    def to_h
      %i[number name communes_count objets_count].map { [_1, send(_1)] }.to_h
    end
  end
end

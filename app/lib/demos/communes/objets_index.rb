# frozen_string_literal: true

module Demos
  module Communes
    class MockedObjetsList
      attr_reader :commune, :objets

      def initialize(commune, objets)
        @commune = commune
        @objets = objets
      end

      def edifice = nil
      def edifices = nil
      def group_by_edifice? = false

      delegate :count, :any?, to: :objets
    end

    class ObjetsIndex < Base
      def template = "communes/objets/index"

      def perform
        @commune = build(:commune)
        @objets_list = MockedObjetsList.new(
          @commune,
          [
            build(:objet, palissy_TICO: "Peinture magistrale"),
            build(:objet, palissy_TICO: "Stalles du choeur : décor peint de la chapelle"),
            build(:objet, palissy_TICO: "Borne kilométrique")
          ]
        )
      end
    end
  end
end

# frozen_string_literal: true

module Communes
  class ObjetCardComponentPreview < ViewComponent::Preview
    def default
      commune = FactoryBot.build(:commune, id: 10).tap(&:readonly!)
      objet = FactoryBot.build(:objet, commune:, id: 20).tap(&:readonly!)
      render Communes::ObjetCardComponent.new(objet:)
    end

    def recensed
      commune = FactoryBot.build(:commune, id: 10).tap(&:readonly!)
      objet = FactoryBot.build(:objet, commune:, id: 20).tap(&:readonly!)
      def objet.current_recensement
        FactoryBot.build(:recensement).tap(&:readonly!)
      end
      render Communes::ObjetCardComponent.new(objet:)
    end
  end
end

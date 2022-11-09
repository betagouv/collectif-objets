# frozen_string_literal: true

class ObjetCardComponentPreview < ViewComponent::Preview
  def default
    objet = FactoryBot.build(:objet, id: 1234).tap(&:readonly!)
    render ObjetCardComponent.new(objet:)
  end
end

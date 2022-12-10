# frozen_string_literal: true

class AdminIdentityComponentPreview < ViewComponent::Preview
  def default
    admin_user = FactoryBot.build(:admin_user).tap(&:readonly!)
    render AdminIdentityComponent.new(admin_user:)
  end
end

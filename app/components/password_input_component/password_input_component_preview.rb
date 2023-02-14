# frozen_string_literal: true

class PasswordInputComponent::PasswordInputComponentPreview < ViewComponent::Preview
  def with_hint
    render PasswordInputComponent.new(name: "user[password]")
  end
end

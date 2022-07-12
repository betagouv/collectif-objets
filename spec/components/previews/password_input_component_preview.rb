# frozen_string_literal: true

class PasswordInputComponentPreview < ViewComponent::Preview
  def with_hint
    render PasswordInputComponent.new(name: "user[password]")
  end
end

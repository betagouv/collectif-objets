# frozen_string_literal: true

class UnfoldComponent::UnfoldComponentPreview < ViewComponent::Preview
  def overflowing
    render UnfoldComponent.new.with_content(
      content_tag(:p, "some long text " * 10) * 10
    )
  end

  def not_overflowing
    render UnfoldComponent.new.with_content(
      content_tag(:p, "some long text " * 10) * 2
    )
  end
end

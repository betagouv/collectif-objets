# frozen_string_literal: true

class PhotoUploadComponentPreview < ViewComponent::Preview
  def default
    render PhotoUploadComponent.new
  end
end

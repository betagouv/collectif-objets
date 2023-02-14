# frozen_string_literal: true

class PhotoUploadComponent::PhotoUploadComponentPreview < ViewComponent::Preview
  def default
    render PhotoUploadComponent.new
  end
end

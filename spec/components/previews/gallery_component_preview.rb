# frozen_string_literal: true

class GalleryComponentPreview < ViewComponent::Preview
  # @param count number
  # @param template select ["full", "small"]
  # @param display_description toggle
  # @param display_gallery_link toggle
  def default(count: 6, template: "full", display_description: true, display_gallery_link: true)
    urls = ([
      "/image-non-renseignee.jpeg"
    ] * 10).first(count)
    photos = urls.map { GalleryComponent::PHOTO.new(original_url: _1, thumb_url: _1, description: "jolie fleur") }
    render(GalleryComponent.new(photos, template:, display_description:, display_gallery_link:))
  end
end

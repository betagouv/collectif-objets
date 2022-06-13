class GalleryComponentPreview < ViewComponent::Preview
  def single_photo
    photos = [
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP51P00156/sap01_51p00156_p.jpg"
    ]
    render(GalleryComponent.new(photos:))
  end

  def with_multiple_images; end
end

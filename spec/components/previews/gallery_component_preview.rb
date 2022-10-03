# frozen_string_literal: true

class GalleryComponentPreview < ViewComponent::Preview
  def single_photo
    urls = [
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP51P00156/sap01_51p00156_p.jpg"
    ]
    render(GalleryComponent.palissy_photos_from_objet(urls))
  end

  # @param count number
  def multiple_photos(count: 6)
    urls = [
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L040680/sap04_80l040680_p.jpg",
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP52W02313/52W02313.JPG",
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L040649/sap04_80l040649_p.jpg",
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L040653/sap04_80l040653_p.jpg",
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L040654/sap04_80l040654_p.jpg",
      "https://s3.eu-west-3.amazonaws.com/pop-phototeque/memoire/AP80L040655/sap04_80l040655_p.jpg"
    ].first(count)
    render(GalleryComponent.palissy_photos_from_objet(urls))
  end
end

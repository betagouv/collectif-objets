# frozen_string_literal: true

class PhotoPresenter
  attr_reader :url, :description, :credit, :embed_path, :id, :thumb_url, :download_url

  attr_accessor :lightbox_path_params, :lightbox_path

  def initialize(url:, description: nil, credit: nil, thumb_url: nil, download_url: nil, id: nil)
    @url = url
    @thumb_url = thumb_url || url
    @description = description
    @download_url = download_url || url
    @credit = credit
    @id = id
  end

  def self.from_attachment(attachment)
    new(
      url: Rails.application.routes.url_helpers.url_for(attachment),
      thumb_url: Rails.application.routes.url_helpers.url_for(attachment.variant(:medium)),
      download_url: Rails.application.routes.url_helpers.rails_blob_path(attachment, disposition: "attachment"),
      credit: "© Licence ouverte",
      id: attachment.id
    )
  end

  def self.from_palissy_photo(palissy_photo, index)
    new(
      url: palissy_photo["url"],
      description: palissy_photo["name"],
      credit: palissy_photo["credit"],
      id: index
    )
  end

  def alt = [description, credit].map(&:presence).compact.join(" - ")
end

# frozen_string_literal: true

class Gallery
  extend Forwardable
  attr_reader :photos

  def initialize(photos: [])
    @photos = photos
  end

  def self.from_recensement(recensement)
    new(
      photos: recensement.photos.order(:created_at).map { Photo.from_attachment(_1) }
    )
  end

  def_delegators :@photos, :count
end

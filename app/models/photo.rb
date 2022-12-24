# frozen_string_literal: true

class Photo
  attr_reader :url, :description, :credit
  alias alt description

  def initialize(url:, description: nil, credit: nil, thumb_url: nil)
    @url = url
    @thumb_url = thumb_url
    @description = description
    @credit = credit
  end

  def thumb_url
    @thumb_url || @url
  end
end

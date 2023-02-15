# frozen_string_literal: true

class PhotoUploadComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(url:)
    @url = url
    super
  end

  private

  attr_accessor :url
end

# frozen_string_literal: true

class PhotoUploadComponent < ApplicationComponent
  include ApplicationHelper

  def initialize(url:)
    @url = url
    super
  end

  private

  attr_accessor :url
end

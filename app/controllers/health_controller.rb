# frozen_string_literal: true

class OnPurposeError < StandardError; end

class HealthController < ApplicationController
  def raise_on_purpose
    raise OnPurposeError, "this is no good"
  end

  def js_error; end

  def slow_image
    raise unless Rails.env.development?

    res = Net::HTTP.get_response(URI.parse(params[:url]))
    raise unless res.code.starts_with?("2")

    sleep(rand(2))
    send_data(res.body, content_type: res.content_type)
  end
end

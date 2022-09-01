# frozen_string_literal: true

return if Rails.configuration.x.environment_specific_name != "production"

Net::HTTP.get_response(
  URI.parse(
    Rails.application.routes.url_helpers.health_raise_on_purpose_url(post_deploy: 1)
  )
)

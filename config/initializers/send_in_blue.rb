require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  config.api_key['api-key'] = Rails.application.credentials.sendinblue&.api_key
  # config.api_key_prefix['api-key'] = 'Bearer'
end

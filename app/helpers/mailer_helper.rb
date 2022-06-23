# frozen_string_literal: true

module MailerHelper
  def png_base64(filename)
    File.open(Rails.root.join("app/assets/images/", filename), "rb") do |img|
      "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
    end
  end
end

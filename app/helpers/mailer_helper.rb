# frozen_string_literal: true

module MailerHelper
  def png_base64(filename)
    Rails.root.join("app/frontend/images/", filename).open("rb") do |img|
      "data:image/png;base64,#{Base64.strict_encode64(img.read)}"
    end
  end
end

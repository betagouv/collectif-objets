# frozen_string_literal: true

module TwoFactorHelper
  def otp_qrcode(user)
    require "rqrcode"

    environment = if Rails.application.staging?
                    "(staging)"
                  elsif !Rails.env.production?
                    Rails.env
                  end
    issuer = ["Collectif Objets", environment].compact.join(" ")
    label = "#{issuer}:#{user.email}"
    uri = user.otp_provisioning_uri(label, issuer:)
    qr = RQRCode::QRCode.new(uri)
    qr.as_svg(module_size: 4, color: "000", fill: "fff").html_safe # rubocop:disable Rails/OutputSafety
  end
end

# frozen_string_literal: true

module TwoFactorHelper
  def otp_qrcode(user, **options)
    require "rqrcode"

    issuer = otp_issuer
    label = "#{issuer}:#{user.email}"
    uri = user.otp_provisioning_uri(label, issuer:)
    qr = RQRCode::QRCode.new(uri)
    qr.as_svg(module_size: 4, color: "000", fill: "fff", svg_attributes: options)
      .html_safe # rubocop:disable Rails/OutputSafety
  end

  def otp_issuer
    environment = if Rails.application.staging?
                    "(staging)"
                  elsif !Rails.env.production?
                    Rails.env
                  end
    ["Collectif Objets", environment].compact.join(" ")
  end
end

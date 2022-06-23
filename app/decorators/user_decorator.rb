# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  include ActionView::Helpers
  delegate_all

  def commune
    super&.decorate
  end

  def magic_token
    return nil if super.blank?

    link_to(
      "#{super} ↗️" || "",
      "/magic-authentication?magic-token=#{super}",
      target: "_blank", rel: "noopener"
    )
  end
end

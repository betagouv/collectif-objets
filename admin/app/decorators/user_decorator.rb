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
      "#{Rails.configuration.x.www_base_url}/magic-authentication?magic-token=#{super}",
      target: "_blank"
    )
  end
end

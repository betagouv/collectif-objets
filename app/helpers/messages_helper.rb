# frozen_string_literal: true

module MessagesHelper
  # rubocop:disable Rails/OutputSafety
  def message_content_html(message)
    return message.text if message.web?

    body_md, signature_md, body_text = %i[body_md signature_md body_text].map { message.inbound_email.send _1 }
    if body_md.present?
      [md_to_html(body_md), md_to_html(signature_md)].join("\n").html_safe
    elsif body_text.present?
      simple_format(body_text).html_safe
    else
      "Le contenu du message n'a pas pu être chargé"
    end
  end
  # rubocop:enable Rails/OutputSafety

  def md_to_html(md_content)
    return nil if md_content.blank?

    Kramdown::Document.new(md_content).to_html
  end
end

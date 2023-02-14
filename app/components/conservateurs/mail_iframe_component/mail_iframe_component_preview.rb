# frozen_string_literal: true

class Conservateurs::MailIframeComponent::MailIframeComponentPreview < ViewComponent::Preview
  def mail_with_body
    mail = Struct.new(:subject, :header, :body).new(
      "Bienvenue chez Collectif Objets",
      {
        "from" => "super@collectif.objets",
        "reply-to" => "coucou@collectif.objets",
        "to" => "jean@lamairie.fr"
      },
      <<-HTML
          <html>
            <h1>bienvenue</h1>
            Et merci
          </html>
      HTML
    )
    render(Conservateurs::MailIframeComponent.new(mail:))
  end

  def mail_with_html_part
    mail = Struct.new(:subject, :header, :html_part).new(
      "Bienvenue chez Collectif Objets",
      {
        "from" => "super@collectif.objets",
        "reply-to" => "coucou@collectif.objets",
        "to" => "jean@lamairie.fr"
      },
      Struct.new(:body).new(
        <<-HTML
            <html>
              <h1>bienvenue</h1>
              Et merci
            </html>
        HTML
      )
    )
    render(Conservateurs::MailIframeComponent.new(mail:))
  end

  def mail_without_body
    mail = Struct.new(:subject, :header).new(
      "Bienvenue chez Collectif Objets",
      {
        "from" => "super@collectif.objets",
        "reply-to" => "coucou@collectif.objets",
        "to" => "jean@lamairie.fr"
      }
    )
    render(Conservateurs::MailIframeComponent.new(mail:))
  end

  private

  def mail; end
end

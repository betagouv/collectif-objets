# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def head_title
    if content_for(:head_title).present?
      "#{content_for(:head_title)} · Collectif Objets"
    else
      "Collectif Objets"
    end
  end

  def badge(color = "", **html_opts)
    html_opts[:class] ||= ""
    html_opts[:class] += " fr-badge fr-badge--sm fr-badge--#{color}"
    content_tag("p", yield, **html_opts)
  end

  def link_to_button(content, path, **kwargs)
    content_tag("form", method: "GET", action: path) do
      content_tag("button", **kwargs) { content }
    end
  end

  def blockquote(content, html_options = {})
    html_options = html_options.with_indifferent_access
    html_options[:class] ||= ""
    html_options[:class] += " fr-callout__text co-white-space-pre-line co-blockquote fr-text--alt"
    content_tag("blockquote", content, **html_options)
  end

  def t_fallback(key)
    return I18n.t(key) if I18n.exists?(key)

    scope = key.split(".").tap(&:pop).join(".")
    I18n.t("#{scope}.other")
  end

  def vite_or_raw_image_tag(src, **kwargs)
    return vite_image_tag(src, **kwargs) if src.is_a?(String) && src.start_with?("images/")

    image_tag(src, **kwargs)
  end

  def communes_policy(*args)
    policy([:communes] + args)
  end

  def conservateurs_policy(*args)
    policy([:conservateurs] + args)
  end

  def icon_span(name, contour: :line, **kwargs)
    content_tag(:span, "", class: "fr-icon-#{name}-#{contour}", "aria-hidden": "true", **kwargs)
  end

  def accessible_icon_span(type: :auto)
    contour = { auto: :line, manual: :fill }[type]
    type_str = { auto: "automatiquement", manual: "manuellement" }[type]
    title = "Accessibilité validée #{type_str}"
    icon_span("checkbox", contour:, title:)
  end

  def active_nav_link?(link)
    active_nav_links&.include?(link)
  end
end

# frozen_string_literal: true

class MessageComponent < ApplicationComponent
  include ApplicationHelper

  with_collection_parameter :message

  def initialize(message:, viewed_by:)
    @message = message
    @viewed_by = viewed_by
    super
  end

  private

  attr_reader :message, :viewed_by

  delegate \
    :author, :created_at, :text, :inbound_email?, :inbound_email, :commune, :skipped_attachments, :sent_at,
    to: :message

  def viewed_by_author?
    viewed_by == author
  end

  def author_name
    return "Vous" if viewed_by_author?

    "#{author} (#{author_class_name})"
  end

  def author_class_name
    { User => "Usager de la commune", Conservateur => "Conservateur", AdminUser => "Support" }[author.class]
  end

  def author_icon
    { Conservateur => "user-star", User => "user", AdminUser => "user-setting" }[author.class]
  end

  def css_classes
    viewed_by_author? ? ["co-margin-left-auto", "co-background--light-grey"] : ["co-background--light-teal"]
  end

  def attachment_path(attachment)
    case viewed_by
    when User
      commune_message_email_attachment_path(commune, message, attachment.index)
    when Conservateur
      conservateurs_commune_message_email_attachment_path(commune, message, attachment.index)
    when AdminUser
      admin_message_email_attachment_path(message, attachment.index)
    end
  end
end

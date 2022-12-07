# frozen_string_literal: true

class UserDecorator < Draper::Decorator
  include ActionView::Helpers
  delegate_all

  def commune
    super&.decorate
  end

  def impersonate_link
    link_to "👤 incarner cet usager", "/admin/users/#{id}/impersonate"
  end
end

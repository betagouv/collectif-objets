# frozen_string_literal: true

module Admin
  class EmailAttachmentsController < BaseController
    include EmailAttachmentsControllerConcern

    def authorize_message = true
  end
end

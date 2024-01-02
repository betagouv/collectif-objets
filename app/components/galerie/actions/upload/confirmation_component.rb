# frozen_string_literal: true

module Galerie
  module Actions
    class Upload
      class ConfirmationComponent < ViewComponent::Base
        attr_reader :attachments_path, :recensement_id, :redirect_path, :message

        def initialize(attachments_path:, recensement_id:, redirect_path:, message:)
          super
          @attachments_path = attachments_path
          @recensement_id = recensement_id
          @redirect_path = redirect_path
          @message = message
        end
      end
    end
  end
end

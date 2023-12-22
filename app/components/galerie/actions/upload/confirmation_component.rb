# frozen_string_literal: true

module Galerie
  module Actions
    module Upload
      class ConfirmationComponent < ViewComponent::Base
        attr_reader :attachments_path, :create_params, :redirect_path, :message

        def initialize(attachments_path:, create_params:, redirect_path:, message:)
          super
          @attachments_path = attachments_path
          @create_params = create_params
          @redirect_path = redirect_path
          @message = message
        end
      end
    end
  end
end

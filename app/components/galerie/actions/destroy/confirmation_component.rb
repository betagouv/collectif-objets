# frozen_string_literal: true

module Galerie
  module Actions
    class Destroy
      class ConfirmationComponent < ViewComponent::Base
        attr_reader :attachment_path, :redirect_path

        def initialize(attachment_path:, redirect_path:)
          super
          @attachment_path = attachment_path
          @redirect_path = redirect_path
        end
      end
    end
  end
end

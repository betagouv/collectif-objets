# frozen_string_literal: true

module Galerie
  module Actions
    module Rotate
      class ButtonComponent < ViewComponent::Base
        include ButtonConcern

        attr_reader :attachment_path, :redirect_path

        def initialize(attachment_path:, redirect_path:, with_text: true)
          super
          @with_text = with_text
          @attachment_path = attachment_path
          @redirect_path = redirect_path
        end
      end
    end
  end
end

# frozen_string_literal: true

module Galerie
  module Actions
    module Upload
      class ButtonComponent < ViewComponent::Base
        include ButtonConcern

        def initialize(with_text: true)
          super
          @with_text = with_text
        end
      end
    end
  end
end

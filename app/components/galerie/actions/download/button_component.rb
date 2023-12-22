# frozen_string_literal: true

module Galerie
  module Actions
    module Download
      class ButtonComponent < ViewComponent::Base
        include ButtonConcern

        attr_reader :url

        def initialize(url:, with_text: true)
          super
          @with_text = with_text
          @url = url
        end
      end
    end
  end
end

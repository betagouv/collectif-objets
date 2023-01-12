# frozen_string_literal: true

module Co
  module AdminNotifications
    module Base
      include ActionView::Helpers
      include Rails.application.routes.url_helpers

      def attachments
        []
      end

      def channel
        nil # will use webhook's default
      end

      def default_url_options
        Rails.application.default_url_options
      end
    end
  end
end

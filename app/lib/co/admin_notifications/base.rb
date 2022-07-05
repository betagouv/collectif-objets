# frozen_string_literal: true

module Co
  module AdminNotifications
    module Base
      include ActionView::Helpers
      include Rails.application.routes.url_helpers

      def attachments
        []
      end

      def admin_url(resource)
        send("admin_#{resource.class.to_s.parameterize}_url", resource)
      end

      def default_url_options
        Rails.application.default_url_options
      end
    end
  end
end

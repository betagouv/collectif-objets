# frozen_string_literal: true

module Co
  module AdminNotifications
    module Base
      include ActionView::Helpers

      def attachments
        []
      end

      def admin_url(resource)
        send("admin_#{resource.class.to_s.parameterize}_url", resource)
      end
    end
  end
end

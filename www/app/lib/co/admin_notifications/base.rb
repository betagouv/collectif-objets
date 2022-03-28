# frozen_string_literal: true

module Co
  module AdminNotifications
    module Base
      include ActionView::Helpers

      def attachments
        []
      end

      def admin_url(resource)
        "#{Rails.configuration.x.admin_base_url}admin/#{resource.class.table_name}/#{resource.id}"
      end
    end
  end
end

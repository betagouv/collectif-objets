# frozen_string_literal: true

module Co
  module Airtable
    class CreateEnrollmentRecord
      def initialize(enrollment)
        @enrollment = enrollment
      end

      def perform
        client = ::Airtable::Client.new(Rails.application.credentials.airtable.api_key)
        table = client.table(Rails.application.credentials.airtable.app_id, "tblTF1D7uN8KzX4to")
        !!table.create(::Airtable::Record.new(airtable_record))
      end

      protected

      def airtable_record
        {
          "Nom" => @enrollment.name,
          "fonction" => @enrollment.role,
          "email" => @enrollment.email,
          "tél" => @enrollment.phone,
          "commune" => @enrollment.commune,
          "commentaire" => @enrollment.notes
        }
      end
    end
  end
end

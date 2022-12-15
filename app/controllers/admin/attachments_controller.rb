# frozen_string_literal: true

module Admin
  class AttachmentsController < BaseController
    def rotate
      attachment = ActiveStorage::Attachment.find(params[:attachment_id])
      raise ArgumentError, "invalid degrees param - only 90 an -90 accepted" \
        unless %w[90 -90].include?(params[:degrees])

      attachment.rotate!(degrees: params[:degrees].to_i)
      render partial: "admin/exports/photo", locals: { photo: attachment }
    end
  end
end

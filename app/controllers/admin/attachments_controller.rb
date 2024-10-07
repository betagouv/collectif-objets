# frozen_string_literal: true

module Admin
  class AttachmentsController < BaseController
    before_action :set_attachment

    def rotate
      raise ArgumentError, "invalid degrees param - only 90 an -90 accepted" \
        unless %w[90 -90].include?(params[:degrees])

      @attachment.rotate!(degrees: params[:degrees].to_i)
      render partial: "admin/exports/memoire/photo", locals: { photo: @attachment }
    end

    def exportable
      @attachment.update!(exportable: params[:exportable] == "true")

      render partial: "admin/exports/memoire/photo", locals: { photo: @attachment }
    end

    def destroy
      @attachment.purge

      render turbo_stream: [turbo_stream.remove("attachment-#{@attachment.id}")]
    end

    private

    def set_attachment
      @attachment = ActiveStorage::Attachment.find(params[:id] || params[:attachment_id])
    end
  end
end

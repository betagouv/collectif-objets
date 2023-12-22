# frozen_string_literal: true

module Conservateurs
  class AttachmentsController < BaseController
    before_action :set_attachment, :validate_redirect_path, only: %i[update destroy]
    before_action :validate_redirect_path

    def create
      @recensement = Recensement.find(params[:recensement_id])
      authorize(::ActiveStorage::Attachment.new(record: @recensement))
      @recensement.photos.attach(params[:new_blob_id])
      query = { "galerie_recensement_#{@recensement.id}_photo_id" => @recensement.photos.last.id }
      redirect_to "#{params[:redirect_path]}?#{query.to_query}"
    end

    def update
      raise ArgumentError, "invalid operation (should be 'rotate')" unless params[:operation] == "rotate"

      raise ArgumentError, "invalid degrees param - only 90 an -90 accepted" \
        unless %w[90 -90].include?(params[:degrees])

      @attachment.rotate!(degrees: params[:degrees].to_i)
      redirect_to(params[:redirect_path])
    end

    def destroy
      @attachment.purge
      redirect_to(params[:redirect_path])
    end

    private

    def set_attachment
      @attachment = ::ActiveStorage::Attachment.find(params[:id])
      authorize(@attachment)
    end

    def validate_redirect_path
      raise ArgumentError, "missing redirect_path" if params[:redirect_path].blank?
    end
  end
end

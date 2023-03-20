# frozen_string_literal: true

module Admin
  class MemoireExportsController < BaseController
    before_action :set_pop_export, only: %i[show destroy]
    before_action :set_departement, only: %i[new create]

    def show
      @pagy, attachments = pagy(@pop_export.recensement_photos_attachments, items: 50)
      @photos = MemoireExportPhoto.from_attachments(attachments)
    end

    def new
      @pagy, attachments = pagy(attachments_arel, items: 50)
      @photos = MemoireExportPhoto.from_attachments(attachments)
    end

    def create
      pop_export = PopExport.new(base: "memoire", departement: @departement, recensements_memoire: recensements)
      if pop_export.save
        ExportMemoireZipJob.perform_async(pop_export.id)
        ExportMemoireCsvJob.perform_async(pop_export.id)
        redirect_to admin_memoire_export_path(pop_export), status: :see_other
      else
        redirect_to \
          new_admin_memoire_export_path(departement_code: pop_export.departement_code),
          alert: "Impossible de générer l'export : #{pop_export.errors.full_messages.to_sentence}"
      end
    end

    def destroy
      @pop_export.destroy!
      redirect_to admin_exports_path, notice: "L'export a été supprimé", status: :see_other
    end

    private

    def set_pop_export
      @pop_export = PopExport.find(params[:id])
    end

    def set_departement
      @departement = Departement.find(params[:departement_code])
    end

    def attachments_arel
      ActiveStorage::Attachment
        .where(record_type: "Recensement")
        .joins(recensement: { objet: [:commune], dossier: {} })
        .where(dossiers: { status: "accepted" })
        .where(communes: { departement_code: @departement })
        .where(recensements: { status: "completed", pop_export_memoire_id: nil })
        .order('communes.nom ASC, objets."palissy_REF" ASC')
    end

    def recensements
      Recensement
        .joins(:objet, dossier: %i[commune])
        .where(dossiers: { status: "accepted" })
        .where(communes: { departement_code: @departement })
        .where(recensements: { status: "completed", pop_export_memoire_id: nil })
    end
  end
end

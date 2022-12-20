# frozen_string_literal: true

module Admin
  class MemoireExportsController < BaseController
    before_action :set_pop_export, only: [:show]
    before_action :set_departement, only: %i[new create]

    def show
      respond_to do |format|
        format.csv do
          csv = MemoireExportCsv.new(@pop_export)
          send_data(csv.to_s, filename: csv.filename, type: "text/csv")
        end
        format.html do
          @pagy, attachments = pagy(@pop_export.recensement_photos_attachments, items: 50)
          @photos = MemoireExportPhoto.from_attachments(attachments)
        end
      end
    end

    def new
      @pagy, attachments = pagy(attachments_arel, items: 50)
      @photos = MemoireExportPhoto.from_attachments(attachments)
    end

    def create
      pop_export = PopExport.new(base: "memoire", departement: @departement)
      if pop_export.save
        recensements.each { pop_export.recensements << _1 }
        redirect_to admin_memoire_export_path(pop_export), status: :see_other
      else
        redirect_to \
          new_admin_memoire_export_path(departement_code: pop_export.departement_code),
          alert: "Impossible de générer l'export : #{pop_export.errors.full_messages.to_sentence}"
      end
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
        .joins("LEFT JOIN recensements ON recensements.id = active_storage_attachments.record_id")
        .joins("LEFT JOIN objets ON objets.id = recensements.objet_id")
        .joins("LEFT JOIN dossiers ON dossiers.id = recensements.dossier_id")
        .joins("LEFT JOIN communes ON communes.id = dossiers.commune_id")
        .where(dossiers: { status: "accepted" })
        .where(communes: { departement_code: @departement })
        .order("communes.nom ASC")
    end

    def recensements
      Recensement
        .joins(:objet, dossier: %i[commune])
        .where(dossiers: { status: "accepted" })
        .where(communes: { departement_code: @departement })
    end
  end
end

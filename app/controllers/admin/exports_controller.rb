# frozen_string_literal: true

module Admin
  class ExportsController < BaseController
    RECENSEMENTS_EXPORTABLE_SQL = "recensements.recensable != false OR recensements.localisation = 'absent'"

    Photo = Struct.new(:attachment, :recensement, keyword_init: true)

    def index
      @departements = Departement
        .order(:code)
        .includes(:dossiers)
        .where.not(dossiers: { accepted_at: nil })
        .includes(recensements: [:photos_attachments])
        .where(RECENSEMENTS_EXPORTABLE_SQL)
    end

    def show
      @departement = Departement.find(params[:id])
      @base = params[:base]
      return set_instance_vars_palissy if @base == "palissy"

      return set_instance_vars_memoire if @base == "memoire"
    end

    private

    def set_instance_vars_palissy
      @recensements = recensements.where.not(localisation: "edifice_initial")
    end

    def set_instance_vars_memoire
      @pagy, attachments = pagy(attachments_arel, items: 50)
      recensements_by_id = recensements.where(id: attachments.pluck(:record_id)).to_a.index_by(&:id)
      @photos = attachments.map do |attachment|
        Photo.new(attachment:, recensement: recensements_by_id[attachment.record_id])
      end
    end

    def dossiers
      Dossier.in_departement(@departement).accepted
    end

    def recensements
      Recensement
        .where(dossier: dossiers)
        .where(RECENSEMENTS_EXPORTABLE_SQL)
        .includes(objet: [:commune])
        .order('communes.nom, objets."palissy_REF"')
    end

    def attachments_arel
      ActiveStorage::Attachment
        .where(record_type: "Recensement")
        .joins("LEFT JOIN recensements ON recensements.id = active_storage_attachments.record_id")
        .joins("LEFT JOIN objets ON objets.id = recensements.objet_id")
        .joins("LEFT JOIN dossiers ON dossiers.id = recensements.dossier_id")
        .joins("LEFT JOIN communes ON communes.id = dossiers.commune_id")
        .where(dossiers: { id: dossiers.to_a.map(&:id) })
        .order("communes.nom ASC")
    end
  end
end

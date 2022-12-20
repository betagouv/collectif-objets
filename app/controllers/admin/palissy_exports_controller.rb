# frozen_string_literal: true

module Admin
  class PalissyExportsController < BaseController
    before_action :set_instance_vars

    def new; end

    def create; end

    private

    def set_instance_vars
      @departement = Departement.find(params[:departement_code])
      @recensements = Recensement
        .joins(:dossier)
        .includes(objet: [:commune])
        .absent_or_recensable
        .where(dossiers: { status: "accepted" })
        .where(communes: { departement_code: @departement })
        .where.not(localisation: "edifice_initial")
        .order('communes.nom, objets."palissy_REF"')
    end
  end
end

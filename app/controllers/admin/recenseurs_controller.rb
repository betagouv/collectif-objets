# frozen_string_literal: true

module Admin
  class RecenseursController < BaseController
    before_action :set_recenseur, only: [:show, :edit, :update, :destroy]

    # GET /admin/recenseurs
    def index
      @ransack = Recenseur.order(created_at: :desc).ransack(params[:q])
      @pagy, @recenseurs = pagy(@ransack.result, items: 20)
      @query = params.dig(:q, :email_or_nom_or_notes_cont)
      render "shared/recenseurs/index"
    end

    # GET /admin/recenseurs/1
    def show
      @accesses = @recenseur.accesses.sorted.includes(:commune, :departement)
      @communes = Commune.none
      if params[:nom]
        @communes = Commune.includes(:departement).limit(20)
                           .ransack(nom_unaccented_cont: params[:nom], s: "departement_code asc, nom asc").result
      end
      respond_to do |format|
        format.turbo_stream { render "shared/recenseur_accesses/form", recenseur: @recenseur }
        format.html { render "shared/recenseurs/show" }
      end
    end

    # GET /admin/recenseurs/new
    def new
      @recenseur = Recenseur.new
      render "shared/recenseurs/new"
    end

    # GET /admin/recenseurs/1/edit
    def edit
      render "shared/recenseurs/edit"
    end

    # POST /admin/recenseurs
    def create
      @recenseur = Recenseur.new(recenseur_params)

      if @recenseur.save
        redirect_to [namespace, @recenseur], notice: "Recenseur créé avec succès."
      else
        render render "shared/recenseurs/new", status: :unprocessable_entity
      end
    end

    # PATCH/PUT /admin/recenseurs/1
    def update
      if @recenseur.update(recenseur_params)
        redirect_to [namespace, @recenseur], notice: "Recenseur modifié.", status: :see_other
      else
        render render "shared/recenseurs/edit", status: :unprocessable_entity
      end
    end

    # DELETE /admin/recenseurs/1
    def destroy
      @recenseur.destroy!
      redirect_to admin_recenseurs_url, notice: "Recenseur supprimé.", status: :see_other
    end

    private

    def set_recenseur
      @recenseur = Recenseur.find(params[:id])
    end

    def recenseur_params
      params.require(:recenseur).permit(:email, :status, :nom, :notes)
    end

    def active_nav_links = ["Recenseurs"]
  end
end

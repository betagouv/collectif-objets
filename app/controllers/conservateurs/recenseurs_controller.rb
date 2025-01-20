# frozen_string_literal: true

module Conservateurs
  class RecenseursController < BaseController
    include NotifyRecenseurOfAccessChange

    before_action :set_recenseur, only: [:show, :edit, :update, :destroy]
    before_action :skip_authorization, only: :show

    # GET /conservateurs/recenseurs
    def index
      @ransack = policy_scope(Recenseur).distinct.order(created_at: :desc).ransack(params[:q])
      @pagy, @recenseurs = pagy(@ransack.result, items: 20)
      @query = params.dig(:q, :email_or_nom_or_notes_cont)
      render "shared/recenseurs/index"
    end

    # GET /conservateurs/recenseurs/1
    def show
      @accesses = @recenseur.accesses.sorted.includes(:commune, :departement).where(commune: policy_scope(Commune))
      @other_accesses = @recenseur.accesses.size > @accesses.load.size
      @communes = Commune.none
      if params[:nom]
        @communes = policy_scope(Commune).includes(:departement).limit(20)
                           .ransack(nom_unaccented_cont: params[:nom], s: "departement_code asc, nom asc").result
      end
      respond_to do |format|
        format.turbo_stream { render partial: "shared/recenseur_accesses/form", recenseur: @recenseur, formats: :html }
        format.html { render "shared/recenseurs/show" }
      end
    end

    # GET /conservateurs/recenseurs/new
    def new
      @recenseur = Recenseur.new
      authorize(@recenseur)
      render "shared/recenseurs/new"
    end

    # GET /conservateurs/recenseurs/1/edit
    def edit
      render "shared/recenseurs/edit"
    end

    # POST /conservateurs/recenseurs
    def create
      @recenseur = Recenseur.find_or_initialize_by(email: recenseur_params[:email])
      authorize(@recenseur)
      @recenseur.nom = recenseur_params[:nom] if recenseur_params[:nom].present?
      if recenseur_params[:notes].present?
        @recenseur.append_to_notes "Notes de #{current_conservateur.full_name} : #{recenseur_params[:notes]}"
      end

      if @recenseur.save
        @accesses = @recenseur.accesses.sorted.includes(:commune, :departement).where(commune: policy_scope(Commune))
        redirect_to [namespace, @recenseur], notice: "Recenseur créé avec succès."
      else
        render "shared/recenseurs/new", status: :unprocessable_entity
      end
    end

    # PATCH/PUT /conservateurs/recenseurs/1
    def update
      if @recenseur.update(recenseur_params)
        redirect_to [namespace, @recenseur], notice: "Recenseur modifié.", status: :see_other
      else
        render "shared/recenseurs/show", status: :unprocessable_entity
      end
    end

    # DELETE /conservateurs/recenseurs/1
    def destroy
      @recenseur.accesses.where(commune: policy_scope(Commune)).delete_all
      @recenseur.destroy if @recenseur.accesses.empty?
      redirect_to [namespace, :recenseurs], notice: "Recenseur supprimé.", status: :see_other
    end

    private

    def set_recenseur
      @recenseur = Recenseur.find(params[:id])
      authorize(@recenseur) unless action_name == "show"
    end

    def recenseur_params
      params.require(:recenseur).permit(:email, :nom, :notes)
    end

    def active_nav_links = ["Recenseurs"]
  end
end

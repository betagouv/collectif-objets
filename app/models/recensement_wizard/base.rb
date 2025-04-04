# frozen_string_literal: true

module RecensementWizard
  STEPS = (1..7).to_a.freeze
  PHOTOS_STEP_NUMER = 4 # not ideal but a quick fix to know where to redirect in recensement photos controller
  class InvalidStep < StandardError; end

  class Base
    include Rails.application.routes.url_helpers
    include ActiveModel::Model
    attr_reader :recensement

    delegate \
      :objet, :commune, :localisation, :recensable, :edifice_nom, :etat_sanitaire,
      :securisation, :notes, :photos, :photo_attachments, :recensable?, :absent?,
      :edifice_initial?, :autre_commune_code_insee,
      :analyse_etat_sanitaire, :analyse_securisation, :persisted?,
      :localisation=, :recensable=, :edifice_nom=, :autre_commune_code_insee=,
      :etat_sanitaire=, :securisation=, :notes=, :attachment_changes,
      to: :recensement

    delegate :step_number, to: :class

    delegate :title, :step_number, to: :class

    def self.title = self::TITLE
    def self.step_number = name.demodulize[-1].to_i

    def initialize(recensement)
      @recensement = recensement
    end

    def self.build_for(step, recensement)
      raise InvalidStep unless step.to_i.in?(STEPS)

      "RecensementWizard::Step#{step}".constantize.new(recensement)
    end

    def next_step_number
      step_number + 1 if step_number < STEPS.last
    end

    def previous_step_number
      return nil if step_number == 1

      prev = step_number - 1
      prev -= 1 while skipped_steps&.include?(prev)
      prev
    end

    def skipped_steps
      # return [] if step_number <= 5 # can we comment this line ?
      s = []
      s += [2, 3, 4, 5] if absent? || recensement.localisation == Recensement::LOCALISATION_DEPLACEMENT_TEMPORAIRE
      s += [3, 4, 5] if recensement.localisation == Recensement::LOCALISATION_DEPLACEMENT_AUTRE_COMMUNE
      s += [4, 5] unless recensable?
      s += [2] if edifice_initial?
      s
    end

    def next_step_title
      return unless next_step_number

      "RecensementWizard::Step#{next_step_number}".constantize::TITLE
    end

    def valid?
      wizard_is_valid = super
      unless recensement.valid?
        errors.merge!(recensement.errors)
        wizard_is_valid = false
      end
      wizard_is_valid
    end

    def update(permitted_params)
      recensement.status = "draft" if @recensement.completed?
      assign_attributes parse_params(permitted_params)
      return false unless valid?

      return true if skip_save?

      reset_recensement_data_for_next_steps
      recensement.save
    end

    def permitted_params = raise NotImplementedError

    def after_success_path
      to_step = confirmation_modal? ? step_number : next_step_number
      edit_commune_objet_recensement_path \
        commune, objet, recensement, step: to_step, **confirmation_modal_path_params.to_h
    end

    # Cette méthode est à re définir dans les sous-classes pour remettre à zéro les données de recensement
    # dans le cas d'un retour en arrière dans le formulaire et du choix d'une autre option
    # Redefine this method in step subclasses to reset data when the user steps back and changes the answers
    def reset_recensement_data_for_next_steps; end

    def confirmation_modal_close_path
      edit_commune_objet_recensement_path(commune, objet, recensement, step: step_number)
    end

    private

    def parse_params(params)
      cloned = params.clone
      %i[recensable confirmation_not_recensable confirmation_introuvable confirmation_no_photos].each do |boolean_param|
        cloned[boolean_param] = cloned[boolean_param] == "true" if cloned[boolean_param].present?
      end
      cloned
    end

    def confirmation_modal_path_params = nil
    def confirmation_modal? = confirmation_modal_path_params.present?
    alias skip_save? confirmation_modal?
  end
end

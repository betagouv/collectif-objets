# frozen_string_literal: true

module RecensementWizard
  STEPS = [1, 2, 3, 4, 5, 6].freeze
  class InvalidStep < StandardError; end

  class Base
    include Rails.application.routes.url_helpers
    include ActiveModel::Model
    attr_reader :recensement

    delegate \
      :objet, :commune, :localisation, :recensable, :edifice_nom, :etat_sanitaire,
      :securisation, :notes, :photos, :photo_attachments, :recensable?, :absent?,
      :analyse_etat_sanitaire, :analyse_securisation, :persisted?,
      to: :recensement

    def initialize(recensement)
      @recensement = recensement
    end

    def self.build_for(step, recensement)
      raise InvalidStep unless step.to_i.in?(STEPS)

      "RecensementWizard::Step#{step}".constantize.new(recensement)
    end

    def title = self.class::TITLE
    def step_number = self.class::STEP_NUMBER

    def next_step_number
      step_number + 1 if step_number < STEPS.last
    end

    def previous_step_number
      return nil if step_number == 1

      prev = step_number - 1
      prev -= 1 while skipped_steps&.include?(prev)
      prev
    end

    def next_step_title
      return unless next_step_number

      "RecensementWizard::Step#{next_step_number}".constantize::TITLE
    end

    def update(permitted_params)
      assign_attributes parse_params(permitted_params)
      errors.merge!(recensement.errors) unless valid?
      return false unless valid?

      return true if skip_save?

      recensement.save
    end

    def permitted_params = raise NotImplementedError

    def after_success_path
      to_step = confirmation_modal? ? step_number : next_step_number
      edit_commune_objet_recensement_path \
        commune, objet, recensement, step: to_step, **confirmation_modal_path_params.to_h
    end

    def skipped_steps_class
      return nil if skipped_steps.empty?

      "co-stepper--skip-steps co-stepper--skip-steps-#{skipped_steps.join('-')}-out-of-6"
    end

    def assign_attributes(attributes)
      attrs_recensement = attributes.to_h.clone.symbolize_keys
      attrs_wizard = attrs_recensement.slice! \
        :localisation, :recensable, :edifice_nom, :etat_sanitaire, :securisation, :notes
      recensement.assign_attributes(attrs_recensement)
      super(attrs_wizard)
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

    def skipped_steps
      return [] if step_number < 5
      return [2, 3, 4] if absent?
      return [3, 4] unless recensable?

      []
    end
  end
end

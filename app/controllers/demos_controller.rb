# frozen_string_literal: true

module DemosDelegationConcern
  extend ActiveSupport::Concern

  included do
    delegate :current_user, to: :demo_object
    alias_method :true_user, :current_user
  end
end

class DemosController < ApplicationController
  include Demos::FactoryBot

  append_before_action :set_demo_banner
  before_action :force_disconnect
  before_action :include_delegation_concern

  def policy(*, **)
    Struct.new(:new?).new(true)
  end
  helper_method :policy

  def show
    demo_object.perform
    demo_object.instance_variables.each { copy_instance_var(_1) }
    render demo_object.template
  end

  private

  def demo_object
    @demo_object ||= demo_class.new(self, variant: params[:variant])
  end

  def demo_class
    "Demos::#{params[:namespace].camelize}::#{params[:name].camelize}".constantize
  end

  def copy_instance_var(name)
    return if name == :@controller

    instance_variable_set(name, demo_object.instance_variable_get(name))
  end

  def set_demo_banner
    @banners << :demo
  end

  def force_disconnect
    alert_type = \
      if method(:current_user).super_method.call
        "compte commune"
      elsif current_conservateur
        "compte conservateur"
      elsif current_admin_user
        "compte admin"
      end
    return unless alert_type

    redirect_back \
      fallback_location: root_path, alert: "Veuillez vous déconnecter de votre #{alert_type} pour voir la page de démo"
  end

  def include_delegation_concern
    extend DemosDelegationConcern
  end
end

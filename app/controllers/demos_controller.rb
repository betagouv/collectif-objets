# frozen_string_literal: true

class DemosController < ApplicationController
  include Demos::FactoryBot
  layout "demo"

  def policy(*, **)
    Struct.new(:new?).new(true)
  end
  helper_method :policy

  delegate :current_user, to: :demo_object

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
end

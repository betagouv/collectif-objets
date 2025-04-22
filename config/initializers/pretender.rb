# frozen_string_literal: true

# slightly adapted from https://github.com/ankane/pretender to work with multiple devise models at once
module Pretender
  class Error < StandardError; end

  module Methods
    def impersonates(scope = :user)
      impersonated_method =:"current_#{scope}"
      impersonate_with = proc { |id| scope.to_s.classify.constantize.find(id:) }
      true_method = :"true_#{scope}"
      session_key = :"impersonated_#{scope}_id"
      readonly_session_key = :"#{scope}_impersonate_write"
      impersonated_var = :"@impersonated_#{scope}"
      stop_impersonating_method = :"stop_impersonating_#{scope}"

      # define methods
      if method_defined?(impersonated_method) || private_method_defined?(impersonated_method)
        alias_method true_method, impersonated_method
      else
        sc = superclass
        define_method true_method do
          # TODO: handle private methods
          unless sc.method_defined?(impersonated_method)
            raise Pretender::Error,
                  "#{impersonated_method} must be defined before the impersonates method"
          end

          sc.instance_method(impersonated_method).bind(self).call
        end
      end
      helper_method(true_method) if respond_to?(:helper_method)

      define_method impersonated_method do
        impersonated_resource = instance_variable_get(impersonated_var) if instance_variable_defined?(impersonated_var)

        if !impersonated_resource && request.session[session_key]
          # only fetch impersonation if user is logged in
          # this is a safety check (once per request) so
          # if a user logs out without session being destroyed
          # or stop_impersonating_user being called,
          # we can stop the impersonation
          if send(true_method) || current_admin_user.present?
            impersonated_resource = impersonate_with.call(request.session[session_key])
            instance_variable_set(impersonated_var, impersonated_resource) if impersonated_resource
          else
            # TODO: better message
            warn "[pretender] Stopping impersonation due to safety check"
            send(stop_impersonating_method)
          end
        end

        impersonated_resource || send(true_method)
      end

      define_method :"impersonate_#{scope}" do |resource, readonly: true|
        raise ArgumentError, "No resource to impersonate" unless resource
        # raise Pretender::Error, "Must be logged in to impersonate" unless send(true_method)

        instance_variable_set(impersonated_var, resource)
        # use to_s for Mongoid for BSON::ObjectId
        request.session[session_key] = resource.id.is_a?(Numeric) ? resource.id : resource.id.to_s
        # Set write permission based on readonly parameter
        request.session[readonly_session_key] = readonly ? "0" : "1"
      end

      define_method :"impersonating_#{scope}_readonly?" do
        request.session[readonly_session_key] != "1"
      end

      define_method stop_impersonating_method do
        remove_instance_variable(impersonated_var) if instance_variable_defined?(impersonated_var)
        request.session.delete(session_key)
        request.session.delete(readonly_session_key)
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  extend Pretender::Methods
end

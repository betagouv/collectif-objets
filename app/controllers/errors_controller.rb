# frozen_string_literal: true

class ErrorsController < ApplicationController
  def show
    # from https://blog.simplificator.com/2015/03/13/handling-errors-in-ruby-on-rails/
    exception = request.env["action_dispatch.exception"]
    wrapper = ActionDispatch::ExceptionWrapper.new(request.env, exception)
    @status_code = wrapper.status_code
    render status: @status_code
  end
end

# frozen_string_literal: true

class AdminIdentityComponent < ViewComponent::Base
  include ApplicationHelper

  attr_reader :admin_user, :user, :impersonating_user, :conservateur, :impersonating_conservateur, :current_layout
  alias impersonating_user? impersonating_user
  alias impersonating_conservateur? impersonating_conservateur

  def initialize(admin_user:, **kwargs)
    @admin_user = admin_user
    @user = kwargs[:user]
    @impersonating_user = kwargs[:impersonating_user]
    @conservateur = kwargs[:conservateur]
    @impersonating_conservateur = kwargs[:impersonating_conservateur]
    @current_layout = kwargs[:current_layout]
    super
  end
end

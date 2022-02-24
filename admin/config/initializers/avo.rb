# For more information regaring these settings check out our docs https://docs.avohq.io
Avo.configure do |config|
  ## == Licensing ==
  config.license = 'community' # change this to 'pro' when you add the license key
  # config.license_key = ENV['AVO_LICENSE_KEY']

  ## == Set the context ==
  config.set_context do
    # Return a context object that gets evaluated in Avo::ApplicationController
  end

  ## == Authentication ==
  config.current_user_method = :current_user
  # config.authenticate_with = {}

  ## == Authorization ==
  # config.authorization_methods = {
  #   index: 'index?',
  #   show: 'show?',
  #   edit: 'edit?',
  #   new: 'new?',
  #   update: 'update?',
  #   create: 'create?',
  #   destroy: 'destroy?',
  # }

  ## == Localization ==
  config.locale = 'fr-FR'

  ## == Customization ==
  config.app_name = 'Collectif Objets'
  config.timezone = 'Europe/Paris'
  config.currency = 'EUR'
  config.per_page = 20
  config.per_page_steps = [20, 50, 100, 200]
  config.via_per_page = 20
  config.default_view_type = :table
  config.id_links_to_resource = true
  # config.full_width_container = false
  config.full_width_index_view = false
  # config.cache_resources_on_index_view = true
  # config.search_debounce = 300
  # config.view_component_path = "app/components"
  # config.display_license_request_timeout_error = true


  # Where should the user be redirected when he hits the `/avo` url
  # config.home_path = nil

  ## == Breadcrumbs ==
  # config.display_breadcrumbs = true
  # config.set_initial_breadcrumbs do
  #   add_breadcrumb "Home", '/avo'
  # end
end

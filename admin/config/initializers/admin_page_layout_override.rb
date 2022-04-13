module AdminPageLayoutOverride
  def build_page(*args)
    within super do
      render "shared/environment_banner"
    end
  end

  # def build_active_admin_head
  #   within super do
  #     render "admin/custom_script_tags"
  #   end
  # end
end

ActiveAdmin::Views::Pages::Base.send :prepend, AdminPageLayoutOverride

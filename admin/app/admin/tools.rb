ActiveAdmin.register_page "Tools" do
  menu priority: 100

  content do
    render partial: 'tools'
  end

  page_action :enqueue_emails_report, method: :post do
    CheckEmailListsJob.perform_async(params[:email])
    redirect_to admin_tools_path, notice: "Vous allez recevoir un mail de rapport !"
  end
end

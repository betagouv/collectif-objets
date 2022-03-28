ActiveAdmin.register_page "Tools" do
  menu label: "⚙️ Outils", priority: 6

  content do
    render partial: 'tools'
  end

  page_action :enqueue_emails_report, method: :post do
    CheckEmailListsJob.perform_async(params[:email])
    redirect_to admin_tools_path, notice: "Vous allez recevoir un mail de rapport !"
  end

  page_action :enqueue_move_sib_contacts, method: :post do
    MoveSibContactsBetweenListsJob.perform_async(params[:list_from_id], params[:list_to_id])
    redirect_to admin_tools_path, notice: "Transfert des contacts en cours !"
  end
end

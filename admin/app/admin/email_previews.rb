ActiveAdmin.register_page 'Email Previews' do

  content do
    div '.'
  end

  sidebar 'Mail Previews' do
    Dir['app/mailer_previews/*_preview.rb'].each do |preview_path|
      preview_mailer = File.basename(preview_path, '.rb')
      mailer = preview_mailer.chomp('_preview')
      div { strong { mailer } }
      preview_mailer_class = preview_mailer.camelize.constantize
      mails = preview_mailer_class.public_instance_methods(false).map(&:to_s).sort
      mails.each do |mail|
        div { link_to mail, {action: :preview, mailer: mailer, mail: mail} }
      end
      br
    end
  end

  page_action :preview do
    mailer_preview_class = "#{params[:mailer]}_preview".camelize.constantize
    @email = mailer_preview_class.new.send(params[:mail])
    ActionMailer::InlinePreviewInterceptor.previewing_email(@email)

    part = @email.find_first_mime_type('text/html') || @email
    @email_content = part.decoded
  end

end

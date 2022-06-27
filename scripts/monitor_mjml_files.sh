while sleep 1; do find ./app/views/*_mailer -iname '*.mjml' | entr -d ./scripts/convert_mjml_files_to_html.sh; done

function convert_mjml() {
  FILEPATH_MJML="$1"
  # FILENAME_MJML=$(basename "$1")
  FILEPATH_HTML=${FILEPATH_MJML%.mjml}.html.erb
  mjml -r $FILEPATH_MJML > $FILEPATH_HTML
  echo "recompiled $FILEPATH_HTML"
}

find ./app/views/*_mailer -iname '*.mjml' | while read file; do convert_mjml "$file"; done

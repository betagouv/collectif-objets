# from https://stackoverflow.com/questions/49709447/execute-a-relative-path-shell-script-from-a-shell-script
srcdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )

source "$srcdir/create_sentry_release.sh"
rails runner "$srcdir/trigger_raise_on_purpose.rb"
bundle exec rails db:migrate

web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 10
worker_serial: bundle exec sidekiq -c 1 -q step_up_recipients
postdeploy: ./scripts/postdeploy.sh

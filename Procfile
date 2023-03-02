web: RAILS_MAX_THREADS=5 bundle exec puma -C config/puma.rb
worker: RAILS_MAX_THREADS=5 bundle exec sidekiq
workerserial: RAILS_MAX_THREADS=1 bundle exec sidekiq -q step_up_recipients
postdeploy: ./scripts/postdeploy.sh

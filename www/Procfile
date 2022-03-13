web: curl https://fichiers.collectif-objets.beta.gouv.fr/Guidederecensement.pdf > public/guide.pdf && bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 10

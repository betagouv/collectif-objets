rm admin/db/schema.rb
rm -r admin/db/migrate
rm admin/config/database.yml
rm admin/app/models

ln -s ../shared admin/shared
ln -s ../shared/db/schema.rb admin/db/schema.rb
ln -s ../shared/db/migrate admin/db/migrate
ln -s ../shared/config/database.yml admin/config/database.yml
ln -s ../shared/app/models admin/app/models
ln -s ../shared/app/jobs admin/app/jobs
ln -s ../shared/app/mailers admin/app/mailers
ln -s ../../shared/app/views/user_mailer admin/app/views/user_mailer
ln -s ../../shared/app/views/admin_mailer admin/app/views/admin_mailer

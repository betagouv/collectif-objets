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
ln -s ../../../shared/app/views/shared/_environment_banner.html.erb admin/app/views/shared/_environment_banner.html.erb

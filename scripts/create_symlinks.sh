rm admin/db/schema.rb
# rm -r admin/db/migrate
rm admin/config/database.yml
rm -r admin/app/models

ln -s ../shared admin/shared
ln -s ../shared/db/schema.rb admin/db/schema.rb
ln -s ../shared/db/migrate admin/db/migrate
ln -s ../shared/config/database.yml admin/config/database.yml
ln -s ../shared/models admin/app/models

rm admin_avo/db/schema.rb
rm admin_avo/config/database.yml
rm -r admin_avo/app/models

ln -s ../shared admin_avo/shared
ln -s ../shared/db/schema.rb admin_avo/db/schema.rb
ln -s ../shared/config/database.yml admin_avo/config/database.yml
ln -s ../shared/models admin_avo/app/models

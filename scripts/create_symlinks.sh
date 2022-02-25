rm www/db/schema.rb
rm www/config/database.yml
rm -r www/app/models

ln -s ../shared www/shared
ln -s ../shared/db/schema.rb www/db/schema.rb
ln -s ../shared/config/database.yml www/config/database.yml
ln -s ../shared/models www/app/models

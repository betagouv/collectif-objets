ls $1 | sed 'p;s/.erb$/.haml/' | xargs -n2 bundle exec html2haml --ruby19-attributes -E utf-8:utf-8
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xE9;/é/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xE8;/è/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xA0;/\&nbsp;/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xAB;/«/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xBB;/»/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xE0;/à/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#x2019;/ʼ/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xFB01;/fi/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#x153;/œ/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xEE;/î/g'
ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/\&#xC0;/À/g'
# ls $1 | sed 's/.erb$/.haml/' | xargs sed -i '' 's/&#xE0;/à/g'


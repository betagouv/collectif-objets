rm -rf vendor/assets/dsfr
mkdir -p vendor/assets/dsfr/dsfr/utility

ln -s ../../../../node_modules/@gouvfr/dsfr/dist/artwork vendor/assets/dsfr/dsfr/artwork
ln -s ../../../../node_modules/@gouvfr/dsfr/dist/dsfr.min.css vendor/assets/dsfr/dsfr/dsfr.min.css
ln -s ../../../../node_modules/@gouvfr/dsfr/dist/favicon vendor/assets/dsfr/dsfr/favicon
ln -s ../../../../node_modules/@gouvfr/dsfr/dist/fonts vendor/assets/dsfr/dsfr/fonts
ln -s ../../../../node_modules/@gouvfr/dsfr/dist/icons vendor/assets/dsfr/dsfr/icons
ln -s ../../../../../node_modules/@gouvfr/dsfr/dist/utility/utility.min.css vendor/assets/dsfr/dsfr/utility/utility.min.css

rm vendor/javascript/@gouvfr--dsfr.js
ln -s ../../node_modules/@gouvfr/dsfr/dist/dsfr.module.min.js vendor/javascript/@gouvfr--dsfr.js


# Symbolic links minimal files to public/dsfr-static for static 404 and 500 html pages...
rm -rf public/dsfr-static

mkdir -p public/dsfr-static/artwork/pictograms/system/
mkdir -p public/dsfr-static/icons/system

ln -s ../../node_modules/@gouvfr/dsfr/dist/dsfr.min.css public/dsfr-static/dsfr.min.css
ln -s ../../node_modules/@gouvfr/dsfr/dist/favicon public/dsfr-static/favicon
ln -s ../../node_modules/@gouvfr/dsfr/dist/fonts public/dsfr-static/fonts
ln -s ../../../../../node_modules/@gouvfr/dsfr/dist/artwork/pictograms/system/technical-error.svg public/dsfr-static/artwork/pictograms/system/technical-error.svg
ln -s ../../../../node_modules/@gouvfr/dsfr/dist/icons/system/external-link-line.svg public/dsfr-static/icons/system/external-link-line.svg

# find public/dsfr-static

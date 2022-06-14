# WWW - Collectif Objets

## Dev

cf le `/README.md` à la racine

## Mails & MJML

- `npm install`
- `./node_modules/.bin/mjml -r app/views/user_mailer/validate_email.html.mjml > app/views/user_mailer/validate_email.html.erb`

## Importer un nouveau département

- `scalingo --app collectif-objets-prod --region osc-secnum-fr1 run "rails runner \"SynchronizeWithPopJob.perform_inline('08')\""`
- `scalingo --app collectif-objets-prod --region osc-secnum-fr1 run "rails runner \"CreateMissingCommunesJob.perform_inline('08')\""`
- geocoder les communes à exclure pour récupérer les codes INSEE, eventuellement avec https://adresse.data.gouv.fr/csv
- hardcoder les codes insee dans admin/app/services/sib_export_communes_csv.rb & déployer
- lancer cet export depuis l'admin de prod
- créer les nouvelles listes et l'importer dans SIB
- dupliquer et adapter les workflows et templates

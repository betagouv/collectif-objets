# WWW - Collectif Objets

## Dev

Setup:

- install rbenv & make sure you have the correct ruby-version installed and selected

```sh
bundle install
bundle exec overcommit --install
```

Dev: `rails server`

## Mails & MJML

- `npm install`
- `./node_modules/.bin/mjml -r app/views/user_mailer/validate_email.html.mjml > app/views/user_mailer/validate_email.html.erb`

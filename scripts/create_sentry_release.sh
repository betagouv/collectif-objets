[[ $HOST == *"staging"* ]] && SENTRY_ENV="staging" || SENTRY_ENV="production"

# build for rails
NAME="$CONTAINER_VERSION-rails"
if sentry-cli releases info --project collectif-objets $NAME &>1
then
  echo "using existing sentry release $NAME"
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project collectif-objets
else
  echo "building new sentry release $NAME"
  sentry-cli releases new --project collectif-objets --finalize $NAME
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project collectif-objets
fi

# build for JS
NAME="$CONTAINER_VERSION-js"
if sentry-cli releases info --project collectif-objets-js $NAME &>1
then
  echo "using existing sentry release $NAME"
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project collectif-objets-js
else
  echo "building new sentry release $NAME"
  sentry-cli releases new --project collectif-objets-js $NAME
  sentry-cli releases files $NAME upload-sourcemaps --project collectif-objets-js /app/public/vite/assets
  sentry-cli releases finalize --project collectif-objets-js $NAME
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project collectif-objets-js
fi

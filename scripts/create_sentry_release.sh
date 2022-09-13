[[ $HOST == *"staging"* ]] && SENTRY_ENV="staging" || SENTRY_ENV="production"

# build for rails
NAME="$CONTAINER_VERSION-rails"
PROJECT=collectif-objets
if sentry-cli releases info --project $PROJECT $NAME &>1
then
  echo "using existing sentry release $NAME"
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project $PROJECT
else
  echo "building new sentry release $NAME"
  sentry-cli releases new --project $PROJECT --finalize $NAME
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project $PROJECT
fi

# build for JS
NAME="$CONTAINER_VERSION-js"
PROJECT=collectif-objets-js
if sentry-cli releases info --project $PROJECT $NAME &>1
then
  echo "using existing sentry release $NAME"
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project $PROJECT
else
  echo "building new sentry release $NAME"
  sentry-cli releases new --project $PROJECT $NAME
  sentry-cli releases files $NAME upload-sourcemaps --project $PROJECT /app/public/vite/assets
  sentry-cli releases finalize --project $PROJECT $NAME
  sentry-cli releases deploys $NAME new --env "$SENTRY_ENV" --project $PROJECT
fi

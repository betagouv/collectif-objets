[[ $HOST == *"staging"* ]] && SENTRY_ENV="staging" || SENTRY_ENV="production"
sentry-cli releases new "$CONTAINER_VERSION"
sentry-cli releases files "$CONTAINER_VERSION" upload-sourcemaps /app/public/vite/assets
sentry-cli releases finalize "$CONTAINER_VERSION"
sentry-cli releases deploys "$CONTAINER_VERSION" new -env "$SENTRY_ENV" --project collectif-objets
sentry-cli releases deploys "$CONTAINER_VERSION" new -env "$SENTRY_ENV" --project collectif-objets-js

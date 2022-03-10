# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@sentry/browser", to: "https://ga.jspm.io/npm:@sentry/browser@6.18.2/esm/index.js"
pin "@sentry/tracing", to: "https://ga.jspm.io/npm:@sentry/tracing@6.18.2/esm/index.js"
pin "@sentry/core", to: "https://ga.jspm.io/npm:@sentry/core@6.18.2/esm/index.js"
pin "@sentry/hub", to: "https://ga.jspm.io/npm:@sentry/hub@6.18.2/esm/index.js"
pin "@sentry/minimal", to: "https://ga.jspm.io/npm:@sentry/minimal@6.18.2/esm/index.js"
pin "@sentry/types", to: "https://ga.jspm.io/npm:@sentry/types@6.18.2/esm/index.js"
pin "@sentry/utils", to: "https://ga.jspm.io/npm:@sentry/utils@6.18.2/esm/index.js"
pin "tslib", to: "https://ga.jspm.io/npm:tslib@1.14.1/tslib.es6.js"

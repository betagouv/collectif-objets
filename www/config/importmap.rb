# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@sentry/browser", to: "@sentry--browser.js" # @6.19.6
pin "@sentry/tracing", to: "@sentry--tracing.js" # @6.19.6
pin "@sentry/core", to: "@sentry--core.js" # @6.19.6
pin "@sentry/hub", to: "@sentry--hub.js" # @6.19.6
pin "@sentry/minimal", to: "@sentry--minimal.js" # @6.19.6
pin "@sentry/types", to: "@sentry--types.js" # @6.19.6
pin "@sentry/utils", to: "@sentry--utils.js" # @6.19.6
pin "tslib" # @1.14.1

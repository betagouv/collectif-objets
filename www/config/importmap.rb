# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/activestorage", to: "activestorage.esm.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "frappe-charts" # @1.6.2 dled from https://cdn.jsdelivr.net/npm/frappe-charts@1.6.2/dist/frappe-charts.min.esm.js
pin "throttle-debounce" # @5.0.0

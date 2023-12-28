# frozen_string_literal: true

# LOCAL PACKAGES
pin "application"
pin "openmaptiles_style"
pin "matomo_tracking"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/stimulus_controllers", under: "stimulus_controllers"
# I absolutely don’t understand this syntax with under and to, but managed
# to make it work thanks to https://github.com/rails/importmap-rails/pull/192
pin_all_from "app/components", under: "components", to: ""

# VENDOR PACKAGES
pin "@rails/activestorage", to: "@rails--activestorage.js" # @7.1.2
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.0
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.0
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @7.1.2
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "nanobar" # @0.4.2
pin "throttle-debounce" # @5.0.0
pin "@kurkle/color", to: "@kurkle--color.js" # @0.3.2
pin "maplibre-gl", preload: false # @3.6.2

# VENDOR PACKAGES MANUALLY DOWNLOADED AND TWEAKED, cf README
pin "chart.js" # @4.4.1
pin "@gouvfr/dsfr", to: "@gouvfr--dsfr.js" # @1.11.0

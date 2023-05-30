import * as Sentry from "@sentry/browser";
import { BrowserTracing } from "@sentry/tracing";
import "@hotwired/turbo-rails"
import "@gouvfr/dsfr/dist/dsfr.module"
import { Application } from '@hotwired/stimulus'
import * as ActiveStorage from '@rails/activestorage'
import { registerControllers } from "stimulus-vite-helpers";

// Sentry
const environmentSpecificName = document.querySelector('meta[name="environment-specific-name"]')?.getAttribute("content")
if (environmentSpecificName && environmentSpecificName != "development") {
  Sentry.init({
    dsn: "https://99d2b66bbb984049aeaa1ec14866be65@sentry.incubateur.net/41",
    integrations: [new BrowserTracing()],
    tracesSampleRate: .2,
    environment: environmentSpecificName
  });
}

// Active Storage
ActiveStorage.start()

// Stimulus
window.Stimulus = Application.start()

const controllers = import.meta.globEager("../stimulus_controllers/**/*_controller.js");
registerControllers(window.Stimulus, controllers);

const identifierForComponentControllerPath = (path) => {
  // inspired by https://github.com/ElMassimo/stimulus-vite-helpers/blob/main/src/index.ts
  const match_data = path.match(/components\/(.*)\/.*_controller\.js/)
  if (!match_data) return null
  return match_data[1].replace(/\//g, "--").replace(/_/g, "-")
}

const componentControllers = import.meta.globEager("../../components/**/*_controller.js");
Object.entries(componentControllers).forEach(([path, controllerModule]) => {
  const identifier = identifierForComponentControllerPath(path)
  if (!identifier || typeof controllerModule.default !== 'function') return
  window.Stimulus.register(identifier, controllerModule.default)
})

import "chartkick"
import "chartkick/chart.js"

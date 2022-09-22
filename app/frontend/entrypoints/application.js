import * as Sentry from "@sentry/browser";
import { BrowserTracing } from "@sentry/tracing";

const environmentSpecificName = document.querySelector('meta[name="environment-specific-name"]')?.getAttribute("content")
if (environmentSpecificName && environmentSpecificName != "development") {
  Sentry.init({
    dsn: "https://99d2b66bbb984049aeaa1ec14866be65@sentry.incubateur.net/41",
    integrations: [new BrowserTracing()],
    tracesSampleRate: .2,
    environment: environmentSpecificName
  });
}

import "@hotwired/turbo-rails"
import "@gouvfr/dsfr/dist/dsfr.module"

import { Application } from '@hotwired/stimulus'
window.Stimulus = Application.start()

import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()

import { registerControllers } from "stimulus-vite-helpers";
const controllers = import.meta.globEager("../stimulus_controllers/**/*_controller.js");
registerControllers(window.Stimulus, controllers);

import PhotoUploadComponent from "../stimulus_controllers_components/photo_upload_controller"
window.Stimulus.register("photo-upload", PhotoUploadComponent)

import PhotosUploadGroupComponent from "../stimulus_controllers_components/photos_upload_group_controller"
window.Stimulus.register("photos-upload-group", PhotosUploadGroupComponent)

import UnfoldComponent from "../stimulus_controllers_components/unfold_controller"
window.Stimulus.register("unfold", UnfoldComponent)

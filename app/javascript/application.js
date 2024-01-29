import "@hotwired/turbo-rails"
import "@gouvfr/dsfr"
import * as ActiveStorage from '@rails/activestorage'

// Active Storage
ActiveStorage.start()

// Stimulus Controllers
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
const application = Application.start()
application.debug = false
window.Stimulus = application
eagerLoadControllersFrom("stimulus_controllers", application)

// for the stimulus controllers attached to viewcomponents we cannot use the eager load
// because the viewcomponent folder structure is not compatible, the registered name would be
// stupidly long
// tip: useful shell command: find app/components -type f -name '*_controller.js'

import LightboxComponentController from "components/galerie/lightbox_component/lightbox_component_controller"
application.register("galerie--lightbox-component", LightboxComponentController)

import GalerieUploadComponentController from "components/galerie/actions/upload/confirmation_component/confirmation_component_controller"
application.register("galerie--actions--upload--confirmation-component", GalerieUploadComponentController)

import PhotoUploadComponentController from "components/photo_upload_component/photo_upload_component_controller"
application.register("photo-upload-component", PhotoUploadComponentController)

import UnfoldComponentController from "components/unfold_component/unfold_component_controller"
application.register("unfold-component", UnfoldComponentController)

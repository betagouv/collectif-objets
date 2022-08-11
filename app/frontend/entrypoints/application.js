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

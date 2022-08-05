console.log('Vite ⚡️ Rails')

import "@hotwired/turbo-rails"

import { Application } from '@hotwired/stimulus'
const application = Application.start()

import * as ActiveStorage from '@rails/activestorage'
ActiveStorage.start()

import { registerControllers } from "stimulus-vite-helpers";
const controllers = import.meta.globEager("../stimulus_controllers/**/*_controller.js");
registerControllers(application, controllers);
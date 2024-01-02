import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

import "./lightbox_component.css"

export default class extends Controller {
  connect() {
    // prevent body from being scrollable when modal is open
    document.querySelector("body").style.overflow = "hidden"
  }

  disconnect() {
    document.querySelector("body").style.overflow = "auto"
  }

  close(_event) {
    // this should prevent closing the lightbox when a dialog is open but it doesn't work
    // because the dialog is closed first
    // if (document.querySelector("dialog[open]")) return;

    Turbo.visit(this.element.dataset.closePath, { frame: this.element.dataset.turboFrame })
  }

  next(_event) {
    if (this.element.dataset.nextPhotoPath == null) return

    Turbo.visit(this.element.dataset.nextPhotoPath, { frame: this.element.dataset.turboFrame })
  }

  previous(_event) {
    if (this.element.dataset.previousPhotoPath == null) return

    Turbo.visit(this.element.dataset.previousPhotoPath, { frame: this.element.dataset.turboFrame })
  }
}

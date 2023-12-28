import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["existingPhoto", "link"]

  toggleLinks(enabled) {
    this.linkTargets.forEach(link => link.toggleAttribute("disabled", !enabled))
  }

  disableLinks() { this.toggleLinks(false) }

  // hacky fix from https://github.com/hotwired/turbo-rails/issues/379
  existingPhotoTargetDisconnected() { this.toggleLinks(true) }
  existingPhotoTargetConnected() { this.toggleLinks(true) }

  // not sure why the autoscroll thing does not work 🤷‍
  scroll() {
    this.scope.element.scrollIntoView({ block: "start" })
  }
}

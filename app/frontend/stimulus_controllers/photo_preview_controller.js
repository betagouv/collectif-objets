import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["wrapper", "image"]

  connect() {
    if (this.imageTarget.complete) return

    this.wrapperTarget.classList.add("co-loading")
  }

  onImageLoad(event) {
    this.wrapperTarget.classList.remove("co-loading")
  }
}

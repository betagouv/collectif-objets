import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  connect() {
    console.log("waza 1")
  }

  toggleDisabled() {
    console.log("waza")
    this.submitTarget.toggleAttribute(
      "disabled",
      this.textareaTarget.value == this.textareaTarget.dataset.originalValue
    )
  }
}

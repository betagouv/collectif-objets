import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  toggleDisabled() {
    this.submitTarget.toggleAttribute(
      "disabled",
      this.textareaTarget.value == this.textareaTarget.dataset.originalValue
    )
  }
}

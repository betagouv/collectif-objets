import { Controller } from "@hotwired/stimulus"
import { debounce } from 'throttle-debounce';

export default class extends Controller {
  static targets = ["container", "form", "textarea", "submit", "accordionButton", "previewExpandedInput", "previewOverlay"]

  connect() {
    this.debouncedSubmit = debounce(1000, () => this.formTarget.requestSubmit()).bind(this)
    this.textareaTarget.addEventListener("input", this.debouncedSubmit)
    this.textareaTarget.addEventListener("input", () => this.containerTarget.classList.add("loading"))
  }

  toggleAccordion() {
    const newValue = this.accordionButtonTarget.getAttribute("aria-expanded") == "false"
    this.previewExpandedInputTarget.value = newValue
  }
}

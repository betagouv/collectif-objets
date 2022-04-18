import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "button", "undo"]

  connect() {
    this.buttonTargets.forEach(e => e.removeAttribute("disabled"))
    this.undoTarget.removeAttribute("disabled")
  }

  usePredefined(event) {
    event.preventDefault()
    const previousContent = this.textareaTarget.value
    this.textareaTarget.value = event.currentTarget.dataset.content
    if (!previousContent) return

    const possibleValues = this.buttonTargets.map(b => b.dataset.content)
    if (possibleValues.includes(previousContent)) return

    this.textareaTarget.dataset.previousContent = previousContent
    this.undoTarget.classList.remove("hide")
  }

  restore(e) {
    e.preventDefault()
    this.textareaTarget.value = this.textareaTarget.dataset.previousContent
    this.undoTarget.classList.add("hide")
  }
}

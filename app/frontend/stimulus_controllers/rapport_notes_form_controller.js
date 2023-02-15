import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["previewPanel", "notesTextarea", "accordionButton"]

  closePreview() {
    if (this.accordionButtonTarget.getAttribute("aria-expanded") == "false") return

    this.accordionButtonTarget.setAttribute("aria-expanded", "false")
    setTimeout(() => this.notesTextareaTarget.focus(), 100)
  }

  submitPreview(event) {
    if (event.currentTarget.getAttribute("aria-expanded") != "false") return

    const form = this.previewPanelTarget.querySelector("form")
    const hiddenField = this.previewPanelTarget.querySelector('input[name="dossier[notes_conservateur]"]')
    hiddenField.value = this.notesTextareaTarget.value
    form.requestSubmit()
  }
}

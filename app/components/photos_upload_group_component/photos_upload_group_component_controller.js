import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputsWrapper",
    "input",
    "template"
  ]

  connect() {
    if (this.inputTargets.filter(inputElt => inputElt.files.length === 0).length > 0)
      return

    this.addUploadGroup()
  }

  addUploadGroup() {
    const clone = this.templateTarget.content.cloneNode(true);
    this.inputsWrapperTarget.appendChild(clone)
  }

  onInputChange(event) {
    if (event.currentTarget.files.length > 1)
      this.splitFileInputMultipleValues(event)

    this.addUploadGroup()
  }

  splitFileInputMultipleValues(event) {
    for (var file of event.currentTarget.files) {
      const newUploadFragment = this.templateTarget.content.cloneNode(true)
      const newInput = newUploadFragment.querySelector("input[type=file]")
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      newInput.files = dataTransfer.files
      this.inputsWrapperTarget.appendChild(newUploadFragment)
    }

    event.currentTarget.closest("div[data-controller=\"photo-upload-component\"]").remove()
  }
}

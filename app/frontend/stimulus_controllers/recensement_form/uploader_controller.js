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

  onInputChange(inputElt) {
    if (inputElt.currentTarget.files.length > 1)
      this.splitFileInputMultipleValues(inputElt)

    this.addUploadGroup()
  }

  splitFileInputMultipleValues(inputElt) {
    for (var file of inputElt.currentTarget.files) {
      const newUploadFragment = this.templateTarget.content.cloneNode(true)
      console.log("newUploadFragment", newUploadFragment)
      const newInput = newUploadFragment.querySelector("input[type=file]")
      console.log("newInput", newInput)
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(file)
      newInput.files = dataTransfer.files
      this.inputsWrapperTarget.appendChild(newUploadFragment)
    }

    inputElt.currentTarget.closest("div[data-controller=\"recensement-form--upload-photo\"]").remove()
  }
}

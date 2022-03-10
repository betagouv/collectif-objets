import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "inputsWrapper",
    "input",
    "template"
  ]

  connect() {
    if (this.inputTargets.filter(elt => elt.files.length === 0).length > 0)
      return

    this.addInput()
  }

  addInput() {
    const clone = this.templateTarget.content.cloneNode(true);
    this.inputsWrapperTarget.appendChild(clone)
  }
}

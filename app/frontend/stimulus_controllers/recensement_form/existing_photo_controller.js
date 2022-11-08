import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "hiddenInput",
    "removeCheckbox",
    "img",
    "deleteIcon",
  ]

  update() {
    this.hiddenInputTarget.toggleAttribute("disabled", this.removeCheckboxTarget.checked)
    this.hiddenInputTarget.toggleAttribute("data-force-disabled", this.removeCheckboxTarget.checked)
    this.imgTarget.classList.toggle("co-semi-transparent", this.removeCheckboxTarget.checked)
    this.deleteIconTarget.classList.toggle("hide", !this.removeCheckboxTarget.checked)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "button", "arrow", "content"]

  connect() {
    this.expanded = false;
  }

  toggle(e) {
    e.preventDefault()
    this.expanded = !this.expanded
    this.wrapperTarget.classList.toggle("expanded", this.expanded)
  }
}

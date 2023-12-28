import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect(e) {
    this.inputTarget = this.scope.element
    this.targetSelector = this.inputTarget.dataset.target
    document
      .querySelectorAll(`input[name="${this.inputTarget.name}"]`)
      .forEach(input => input.addEventListener("change", () => this.refresh()))
    this.refresh()
  }

  refresh() {
    const target = document.querySelector(this.targetSelector)
    target.querySelectorAll("label").forEach(l => l.classList.toggle("co-text--muted", !this.inputTarget.checked))
    target.querySelectorAll("input").forEach(l => l.disabled = !this.inputTarget.checked)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

  connect() {
    this.maxHeightPx = Number(this.contentTarget.dataset.maxHeight)
    this.contentTarget.style.maxHeight = `${this.maxHeightPx}px`
    this.refresh()
  }

  refresh() {
    if (!this.hasButtonTarget) return
    const overflows = this.contentTarget.offsetHeight >= (this.maxHeightPx - 1)
    this.buttonTarget.classList.toggle("hide", !overflows)
    this.contentTarget.classList.toggle("co-fade-overflow", overflows)
  }

  displayAll() {
    this.contentTarget.style.maxHeight = null
    this.buttonTarget.parentElement.removeChild(this.buttonTarget)
    this.contentTarget.classList.remove("co-fade-overflow")
  }
}

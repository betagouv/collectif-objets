import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.retryCount = 0;
    this.openModal()
  }

  openModal() {
    if (!window.dsfr) return this.enqueueRetry()

    const dsfrElt = window.dsfr(this.element)
    if (!dsfrElt) return this.enqueueRetry()

    dsfrElt.modal.disclose()
  }

  enqueueRetry() {
    this.retryCount++
    if (this.retryCount > 3) return

    window.setTimeout(() => this.openModal(), [0, 500, 1000, 1000][this.retryCount])
  }
}

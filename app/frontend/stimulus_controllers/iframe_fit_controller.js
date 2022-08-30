import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iframe"]

  connect() {
    this.refit()
    setTimeout(() => this.refit(), 200)
  }

  refit() {
    this.iframeTarget.height = this.iframeTarget.contentWindow.document.body.scrollHeight
  }
}
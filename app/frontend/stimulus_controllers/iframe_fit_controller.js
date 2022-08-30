import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["iframe"]

  connect() {
    this.iframeTarget.height = this.iframeTarget.contentWindow.document.body.scrollHeight
  }
}
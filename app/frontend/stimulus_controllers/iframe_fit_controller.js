import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.refit()
    setTimeout(() => this.refit(), 200)
  }

  refit() {
    this.element.height = this.element.contentWindow.document.body.scrollHeight
  }
}

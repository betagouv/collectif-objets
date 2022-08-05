import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "input"]

  initialize() {
    this.visible = this.inputTarget.type == "input"
    this.render()
  }

  toggle() {
    this.visible = !this.visible
    this.render()
  }

  render() {
    this.inputTarget.type = this.visible ? "input" : "password"
    this.buttonTarget.innerHTML = this.visible ? "Cacher" : "Afficher"
  }
}

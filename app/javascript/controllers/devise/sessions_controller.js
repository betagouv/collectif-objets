import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["magicLinkForm"]
  connect() {
    console.log("COUCOU!")
  }
  toggleMagicLinkForm(event) {
    event.currentTarget.setAttribute("disabled", "disabled")
    this.magicLinkFormTarget.classList.remove("hide");
  }
}

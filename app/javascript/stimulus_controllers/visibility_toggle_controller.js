import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section", "button"]

  toggle() {
    this.sectionTarget.style.display = "none";
  }
}

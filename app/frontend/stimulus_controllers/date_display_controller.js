import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hint", "input"]

  connect() {
    this.DAYS = ["", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
    this.refresh(this.inputTarget.value)
  }

  refresh(dateRaw) {
    if (!dateRaw) return

    this.hintTarget.innerHTML = this.DAYS[(new Date(dateRaw)).getDay()]
  }

  onChange(event) {
    this.refresh(event.currentTarget.value)
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  checkAll(event) {
    event.preventDefault()
    this.toggleAll(true)
    return false
  }

  uncheckAll(event) {
    event.preventDefault()
    this.toggleAll(false)
  }

  toggleAll(value) {
    this.checkboxTargets.forEach(c => {
      if (c.disabled) return
      c.checked = value
    })
  }
}
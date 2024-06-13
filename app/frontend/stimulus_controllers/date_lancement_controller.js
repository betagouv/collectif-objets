import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  set(event) {
    const source = event.target
    const index = this.targets.indexOf(source)
    const input = this.targets[index + 1]
    if (!input) return

    input.value = this.addDays(new Date(source.value), 14)
    input.dispatchEvent(new Event("change"))
  }

  addDays(date, days) {
    var newDate = new Date(date.valueOf())
    newDate.setDate(newDate.getDate() + days)
    return newDate.toISOString().substring(0, 10)
  }

  get targets() {
    return Array(...this.element.querySelectorAll("input[type=date]"))
  }
}

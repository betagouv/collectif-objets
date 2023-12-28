import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button"]

  set(event) {
    event.preventDefault()

    const button = event.currentTarget
    const inputGroup = button.closest("div[class=fr-input-group]")
    const previousInputGroup = inputGroup.previousElementSibling
    if (!previousInputGroup) return

    const previousInput = previousInputGroup.querySelector("input[type=date]")

    const input = inputGroup.querySelector("input[type=date]")

    const jumpedDate = this.addDays(new Date(previousInput.value), 14)
    input.value = jumpedDate.toISOString().substring(0, 10)
    input.dispatchEvent(new Event("change"))
  }

  addDays(date, days) {
    var newDate = new Date(date.valueOf());
    newDate.setDate(newDate.getDate() + days);
    return newDate;
  }
}

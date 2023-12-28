import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggler", "dependent"]

  initialize() {
    this.refresh()
  }

  refresh() {
    const toggleValue = this.togglerTarget.checked
    this.dependentTargets.forEach(input => {
      if (toggleValue)
        input.removeAttribute("disabled")
      else
        input.setAttribute("disabled", "disabled")
      input.closest("div.fr-input-group")?.classList?.toggle("fr-input-group--disabled", !toggleValue)
    })
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "toggler"]

  initialize() {
    this.toggle()
  }

  toggle() {
    this.#update(this.togglerTargets, false)
    this.#update(this.#selectedToggler, true)
  }

  // Private
  get #selectedToggler() {
    return this.element.querySelectorAll(`#select-toggler-${this.selectTarget.value}`)
  }

  #update(elements, visible) {
    if (elements.size == 0) return

    elements.forEach(toggler => {
      toggler.classList.toggle("hide", !visible)
      toggler.querySelectorAll("select, input").forEach(el => el.disabled = !visible)
    })
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  connect() {
    this.buttonTarget.addEventListener("mousemove", () => {
      this.contentTarget.classList.add("co-copy-to-clipboard--active")
    })
    this.buttonTarget.addEventListener("mouseleave", () => {
      this.contentTarget.classList.remove("co-copy-to-clipboard--active")
    })
  }

  copy(e) {
    e.preventDefault()
    const content = this.contentTarget.dataset.value || this.contentTarget.innerHTML;
    navigator.clipboard.writeText(content)
    this.buttonTarget.classList.remove("fr-icon-todo-line")
    this.buttonTarget.classList.add("fr-icon-check-line")
    window.setTimeout(() => {
      this.buttonTarget.classList.remove("fr-icon-check-line")
      this.buttonTarget.classList.add("fr-icon-todo-line")
    }, 1000)
    return false
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "original",
    "select",
    "analyse",
    "previewBadge",
    "override",
    "validate",
    "cancel",
  ]

  override(event) {
    event.preventDefault();
    this.originalTarget.classList.add("co-text--strikethrough", "co-semi-transparent")
    this.selectTarget.classList.remove("hide")
    this.validateTarget.classList.remove("hide")
    this.cancelTarget.classList.remove("hide")
    this.selectTarget.removeAttribute("disabled")
    this.overrideTarget.classList.add("hide")
    if (this.hasAnalyseTarget)
      this.analyseTarget.classList.add("hide")
    this.previewBadgeTargets.forEach(t => t.classList.add("hide"))
  }

  validate(event) {
    event.preventDefault()
    this.selectTarget.classList.add("hide")
    this.validateTarget.classList.add("hide")
    // this.cancelTarget.classList.add("hide")
    this.overrideTarget.classList.remove("hide")
    this.previewBadgeTargets.find(t => t.dataset.value == this.selectTarget.value).classList.remove("hide")
  }

  cancel(event) {
    event.preventDefault()
    this.originalTarget.classList.remove("co-text--strikethrough", "co-semi-transparent")
    this.selectTarget.setAttribute("disabled", "disabled")
    this.selectTarget.classList.add("hide")
    this.validateTarget.classList.add("hide")
    this.cancelTarget.classList.add("hide")
    this.overrideTarget.classList.remove("hide")
    this.previewBadgeTargets.forEach(e => e.classList.add("hide"))
  }
}

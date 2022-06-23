import { Controller } from "@hotwired/stimulus"
import { throttle } from 'throttle-debounce';

export default class extends Controller {
  static targets = ["badge"]

  initialize() {
    this.throttledHideBadge = throttle(400, () => this.hideBadge()).bind(this)
    window.setTimeout(() => this.hideBadge(), 1000)
  }

  hideBadge() {
    if (!this.hasBadgeTarget) return

    this.badgeTarget.classList.toggle("co-opacity--0", true)
  }
}

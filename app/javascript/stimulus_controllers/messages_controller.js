import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list"]

  connect() {
    this.scrollToBottom()
    new MutationObserver(
      (mutationList, _observer) => {
        if (!mutationList.some(mutation => mutation.addedNodes)) return
        this.scrollToBottom()
      }
    ).observe(this.listTarget, { childList: true })
  }
  scrollToBottom() {
    this.listTarget.scrollTop = this.listTarget.scrollHeight
  }

}

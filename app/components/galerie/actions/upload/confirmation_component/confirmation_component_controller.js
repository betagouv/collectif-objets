import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["uploadForm", "uploadFileInput", "uploadButton"]

  triggerSelectFile(event) {
    event.preventDefault()
    this.uploadFileInputTarget.click()
  }

  triggerSubmit(_event) {
    this.uploadButtonTarget.disabled = true
    this.uploadFormTarget.requestSubmit()
  }
}

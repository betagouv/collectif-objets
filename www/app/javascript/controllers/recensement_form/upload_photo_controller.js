import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "wrapper",
    "uploadGroup",
    "input",
    "img",
    "preview",
  ]

  connect() {
    this.refreshPreview()
  }


  refreshPreview() {
    if (this.inputTarget.files.length === 0) {
    } else {
      this.imgTarget.src = URL.createObjectURL(this.inputTarget.files[0])
      this.previewTarget.classList.remove("hide")
      this.uploadGroupTarget.classList.add("hide")
    }
  }

  remove(event) {
    this.wrapperTarget.remove()
    event.preventDefault()
  }

  disconnect() {
    document.dispatchEvent(new Event("refreshFields"))
  }
}

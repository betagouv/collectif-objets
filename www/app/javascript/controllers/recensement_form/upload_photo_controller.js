import { Controller } from "@hotwired/stimulus"

function humanFileSize(number) {
  if (number < 1024) {
    return number + 'bytes';
  } else if (number >= 1024 && number < 1048576) {
    return (number / 1024).toFixed(1) + 'KB';
  } else if (number >= 1048576) {
    return (number / 1048576).toFixed(1) + 'MB';
  }
}

export default class extends Controller {
  static targets = [
    "wrapper",
    "uploadGroup",
    "input",
    "img",
    "preview",
    "metadata"
  ]

  connect() {
    this.refreshPreview()
  }

  refreshPreview() {
    if (this.inputTarget.files.length === 0) {
    } else {
      const file = this.inputTarget.files[0]
      this.imgTarget.src = URL.createObjectURL(file)
      this.metadataTarget.innerHTML = `${file.type} - ${humanFileSize(file.size)}`
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

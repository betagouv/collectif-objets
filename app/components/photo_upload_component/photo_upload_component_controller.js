import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import Nanobar from "nanobar"
import "./photo_upload_component.css"

function humanFileSize(number) {
  if (number < 1024) {
    return number + 'bytes'
  } else if (number >= 1024 && number < 1048576) {
    return (number / 1024).toFixed(1) + 'KB'
  } else if (number >= 1048576) {
    return (number / 1048576).toFixed(1) + 'MB'
  }
}

export default class extends Controller {
  static targets = [
    "wrapper",
    "uploadGroup",
    "input",
    "img",
    "preview",
    "metadata",
    "progress",
    "nanobar",
    "ctaWithCapture",
    "ctaWithoutCapture",
    "uploadButton",
    "removeButton"
  ]

  connect() {
    const tmpElt = document.createElement('input')
    this.captureSupported = tmpElt.capture != undefined
    this.enableButtons()
    this.refreshPreview()
    this.triggerUpload()
  }

  enableButtons() {
    // form gets submitted if buttons are clicked before JS is loaded
    this.uploadButtonTargets.forEach(button => {
      button.disabled = false
      button.removeAttribute("data-force-disabled")
    })
    document.dispatchEvent(new Event("refreshFields"))
  }

  triggerUpload() {
    const files = Array.from(this.inputTarget.files)
    if (files.length == 0 || files.length > 1) return
    // wait for multiple file inputs to be splitted by group component

    this.uploadFile(files[0])
    this.nanobar = new Nanobar({ target: this.nanobarTarget })
    this.progressTarget.innerText = `chargement démarré …`
  }

  directUploadWillStoreFileWithXHR(xhr) {
    // console.log("in directUploadWillStoreFileWithXHR")
    xhr.upload.addEventListener("progress", event => this.uploadRequestDidProgress(event))
    this.progressTarget.innerText = `chargement en cours …`
  }

  uploadRequestDidProgress(event) {
    // console.log("in uploadRequestDidProgress")
    const progress = event.loaded / event.total * 100
    if (!progress) return

    this.progressTarget.innerText = `chargée à ${Math.round(progress)}%`
    this.nanobar.go(progress)
  }

  uploadFile(file) {
    this.inputTarget.disabled = true // so it does re-upload on form submit
    this.inputTarget.setAttribute("data-uploading", "true")
    new DirectUpload(file, this.inputTarget.dataset.directUploadUrl, this).create(
      (error, blob) => {
        if (error) {
          this.inputTarget.disabled = false
          console.log("ERROR on direct upload !", error)
        } else {
          const hiddenField = document.createElement('input')
          hiddenField.setAttribute("type", "hidden")
          hiddenField.setAttribute("value", blob.signed_id)
          hiddenField.name = this.inputTarget.name
          this.inputTarget.after(hiddenField)
          this.removeButtonTarget.disabled = false
          this.inputTarget.removeAttribute("data-uploading")
          document.dispatchEvent(new Event("refreshFields"))
        }
      }
    )
  }

  refreshPreview() {
    this.ctaWithCaptureTarget.classList.toggle("hide", !this.captureSupported)
    this.ctaWithoutCaptureTarget.classList.toggle("hide", this.captureSupported)
    if (this.inputTarget.files.length === 0) {
    } else {
      const file = this.inputTarget.files[0]
      this.imgTarget.src = URL.createObjectURL(file)
      this.metadataTarget.innerHTML = `${file.type.split("/").pop()} - ${humanFileSize(file.size)}`
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

  triggerBrowse(e) {
    e.preventDefault()
    this.inputTarget.click()
  }

  triggerCapture(e) {
    e.preventDefault()
    this.inputTarget.setAttribute("capture", "environment")
    this.inputTarget.click()
    this.inputTarget.removeAttribute("capture")
  }
}

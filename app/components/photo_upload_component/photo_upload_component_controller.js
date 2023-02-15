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
  static targets = ["wrapper", "input", "submit",  "nanobar", "progressText"]

  connect() {
    const tmpElt = document.createElement('input')
    this.captureSupported = tmpElt.capture !== undefined
    this.formTarget = this.inputTarget.closest("form")
    this.submitTarget.remove()
    this.toggleDependentLinks(true)
  }

  triggerUpload() {
    const files = Array.from(this.inputTarget.files)
    if (files.length !== 1) return

    this.nanobar = new Nanobar({ target: this.nanobarTarget })
    this.progressTextTarget.innerHTML = `chargement démarré …`
    this.toggleDependentLinks(false)
    this.uploadFile(files[0])
    document.querySelector(".fr-input-group--error")?.classList.remove("fr-input-group--error")
    document.querySelectorAll(".fr-error-text,.fr-alert.fr-alert--error").forEach(e => e.remove())

  }

  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", event => this.uploadRequestDidProgress(event))
    this.progressTextTarget.innerHTML = `chargement en cours …`
  }

  toggleDependentLinks(enabled) {
    document
      .querySelectorAll('[data-recensement-form-step-target="link"]')
      .forEach(link => link.toggleAttribute("disabled", !enabled))
  }

  uploadRequestDidProgress(event) {
    // console.log("in uploadRequestDidProgress")
    const progress = event.loaded / event.total * 100
    if (!progress) return

    this.progressTextTarget.innerHTML = `chargée à ${Math.round(progress)}%`
    this.nanobar.go(progress)
  }

  uploadFile(file) {
    this.inputTarget.disabled = true // so it does re-upload on form submit
    new DirectUpload(file, this.wrapperTarget.dataset.directUploadUrl, this).create(
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
          this.inputTarget.removeAttribute("data-uploading")
          this.progressTextTarget.innerHTML = "photo en cours d’ajout …"
          this.formTarget.requestSubmit()
        }
      }
    )
  }

  // triggerBrowse(e) {
  //   e.preventDefault()
  //   this.inputTarget.click()
  // }
  //
  // triggerCapture(e) {
  //   e.preventDefault()
  //   this.inputTarget.setAttribute("capture", "environment")
  //   this.inputTarget.click()
  //   this.inputTarget.removeAttribute("capture")
  // }
}

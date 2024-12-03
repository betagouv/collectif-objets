import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"
import Nanobar from "nanobar"
import "./photo_upload_component.css"

export default class extends Controller {
  static targets = ["input", "submit", "nanobar", "progressText"]
  static values = { url: String }

  connect() {
    this.submitTarget.remove()
    this.toggleDependentLinks(true)
  }

  disconnect() {
    this.nanobar = null
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
    const progress = event.loaded / event.total * 100
    if (!progress) return

    this.progressTextTarget.innerHTML = `chargée à ${Math.round(progress)}%`
    this.nanobar.go(progress)
  }

  uploadFile(file) {
    this.inputTarget.disabled = true // so it does re-upload on form submit
    new DirectUpload(file, this.urlValue, this).create(
      (error, blob) => {
        if (error) {
          this.inputTarget.disabled = false
          this.toggleDependentLinks(true)
          this.progressTextTarget.innerHTML = "Échec d'envoi du fichier"
          console.log("ERROR on direct upload !", error)
        } else {
          const hiddenField = document.createElement('input')
          hiddenField.setAttribute("type", "hidden")
          hiddenField.setAttribute("value", blob.signed_id)
          hiddenField.name = this.inputTarget.name
          this.inputTarget.after(hiddenField)
          this.inputTarget.removeAttribute("data-uploading")
          this.progressTextTarget.innerHTML = "photo en cours d’ajout …"
          this.element.requestSubmit()
        }
      }
    )
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "localisation",
    "recensable",
    "edificeNom",
    "etatSanitaireEdifice",
    "etatSanitaire",
    "securisation",
    "photos",
    "skipPhotos",
    "notes",
    "form",
    "submit"
  ]

  connect() {
    this.refreshFields()
    this.refreshListener = () => { this.refreshFields(); }
    document.addEventListener("refreshFields", this.refreshListener)
  }

  disconnect() {
    document.removeEventListener("refreshFields", this.refreshListener)
  }

  getCurrentValues() {
    return {
      confirmation: this.formTarget.
        querySelector('input[name="recensement[confirmation]"]').checked,
      localisation: this.formTarget.
        querySelector('input[name="recensement[localisation]"]:checked')?.value,
      recensable: this.formTarget
        .querySelector('input[name="recensement[recensable]"]:checked')
        ?.value == "true",
      photosUploaded: Array.from(
        this.formTarget
          .querySelectorAll('input[name="recensement[photos][]"][type=file]')
      ).some(e => e.files.length > 0) ||
        this.formTarget
          .querySelectorAll("input[name=remove_photo]:not(:checked)").length > 0,
      skipPhotos: this.formTarget.
        querySelector('input[name="recensement[skip_photos]"]').checked,
    }
  }

  toggleSection(sectionElt, enabled) {
    sectionElt.querySelector("legend")?.classList?.
      toggle("co-legend--disabled", !enabled)
    sectionElt.querySelectorAll('input:not([type=hidden]):not([data-force-disabled]), textarea:not([data-force-disabled]),button:not([data-force-disabled])')
      .forEach(elt => elt.toggleAttribute("disabled", !enabled))
    sectionElt.querySelectorAll('.fr-input-group:not([data-force-disabled]), .fr-upload-group:not([data-force-disabled])')
      .forEach(elt => elt.classList.toggle("fr-input-group--disabled", !enabled))
  }

  refreshFields() {
    const {
      confirmation, localisation, recensable, photosUploaded, skipPhotos
    } = this.getCurrentValues()
    this.toggleSection(this.localisationTarget, confirmation)
    this.toggleSection(this.edificeNomTarget, confirmation && localisation == "autre_edifice")
    this.toggleSection(this.recensableTarget, confirmation && ["edifice_initial", "autre_edifice"].includes(localisation))
    const mainFieldsCondition = confirmation && ["edifice_initial", "autre_edifice"].includes(localisation) && recensable
    this.toggleSection(this.etatSanitaireEdificeTarget, mainFieldsCondition)
    this.toggleSection(this.etatSanitaireTarget, mainFieldsCondition)
    this.toggleSection(this.securisationTarget, mainFieldsCondition)
    this.toggleSection(this.photosTarget, mainFieldsCondition && !skipPhotos)
    this.toggleSection(this.skipPhotosTarget, mainFieldsCondition && !photosUploaded)
    this.toggleSection(this.notesTarget, confirmation)
    this.submitTarget.toggleAttribute("disabled", !confirmation)
  }

  disableSubmit() {
    this.submitTarget.toggleAttribute("disabled", true)
    this.showLoader()
  }

  showLoader() {
    for (const className of ["fr-fi-refresh-line", "fr-btn--icon-right", "co-btn--icon-spinning"])
      this.submitTarget.classList.toggle(className, true)
  }

  hideLoader() {
    for (const className of ["fr-fi-refresh-line", "fr-btn--icon-right", "co-btn--icon-spinning"])
      this.submitTarget.classList.toggle(className, false)
  }
}

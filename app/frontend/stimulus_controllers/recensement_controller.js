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
    "confirmationPasDePhotos",
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
      confirmationSurPlace: this.formTarget.
        querySelector('input[type=checkbox][name="recensement[confirmation_sur_place]"]').checked,
      localisation: this.formTarget.
        querySelector('input[name="recensement[localisation]"]:checked')?.value,
      recensable: this.formTarget
        .querySelector('input[name="recensement[recensable]"]:checked')
        ?.value == "true",
      photosUploaded:
        this.formTarget
          .querySelectorAll('input[name="recensement[photos][]"][type=hidden]:not([value=""]):not([disabled])').length > 0 ||
        this.formTarget
          .querySelectorAll("input[name=remove_photo]:not(:checked)").length > 0,
      confirmationPasDePhotos: this.formTarget.
        querySelector('input[type=checkbox][name="recensement[confirmation_pas_de_photos]"]').checked,
      photosUploading:
        this.formTarget.querySelectorAll('input[name="recensement[photos][]"][data-uploading]').length > 0
    }
  }

  toggleSection(sectionElt, enabled) {
    sectionElt.querySelector("legend")?.classList?.
      toggle("co-legend--disabled", !enabled)
    sectionElt.querySelectorAll('input:not([data-force-disabled]):not([type=file]), textarea:not([data-force-disabled]), button:not([data-force-disabled])')
      .forEach(elt => elt.toggleAttribute("disabled", !enabled))
    sectionElt.querySelectorAll('.fr-input-group:not([data-force-disabled]), .fr-upload-group:not([data-force-disabled])')
      .forEach(elt => elt.classList.toggle("fr-input-group--disabled", !enabled))
  }

  refreshFields() {
    const {
      confirmationSurPlace, localisation, recensable, photosUploaded, confirmationPasDePhotos, photosUploading
    } = this.getCurrentValues()
    this.toggleSection(this.localisationTarget, confirmationSurPlace)
    this.toggleSection(this.edificeNomTarget, confirmationSurPlace && localisation == "autre_edifice")
    this.toggleSection(this.recensableTarget, confirmationSurPlace && ["edifice_initial", "autre_edifice"].includes(localisation))
    const mainFieldsCondition = confirmationSurPlace && ["edifice_initial", "autre_edifice"].includes(localisation) && recensable
    this.toggleSection(this.etatSanitaireEdificeTarget, mainFieldsCondition)
    this.toggleSection(this.etatSanitaireTarget, mainFieldsCondition)
    this.toggleSection(this.securisationTarget, mainFieldsCondition)
    this.toggleSection(this.photosTarget, mainFieldsCondition && !confirmationPasDePhotos)
    this.toggleSection(this.confirmationPasDePhotosTarget, mainFieldsCondition && !photosUploaded && !photosUploading)
    this.toggleSection(this.notesTarget, confirmationSurPlace)
    this.submitTarget.toggleAttribute("disabled", !(confirmationSurPlace && !photosUploading))
  }

  disableSubmit() {
    this.submitTarget.toggleAttribute("disabled", true)
    this.showLoader()
  }

  showLoader() {
    for (const className of ["fr-icon-refresh-line", "fr-btn--icon-right", "co-btn--icon-spinning"])
      this.submitTarget.classList.toggle(className, true)
  }

  hideLoader() {
    for (const className of ["fr-icon-refresh-line", "fr-btn--icon-right", "co-btn--icon-spinning"])
      this.submitTarget.classList.toggle(className, false)
  }
}

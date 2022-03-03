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
    "form"
  ]

  connect() {
    document.querySelectorAll(`
      input[name="recensement[confirmation]"],
      input[name="recensement[localisation]"],
      input[name="recensement[recensable]"],
      input[name="recensement[skip_photos]"],
      input[name="remove_photo"]
    `)
      .forEach(elt => elt.addEventListener("change", _e => this.refreshFields()))
    this.refreshFields()
    document.addEventListener("refreshFields", () => this.refreshFields())
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
    sectionElt.querySelectorAll('input:not([type=hidden]), textarea')
      .forEach(elt => elt.toggleAttribute("disabled", !enabled))
    sectionElt.querySelectorAll('.fr-input-group, .fr-upload-group')
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
    this.toggleSection(this.notesTarget, confirmation && recensable)
    document.querySelector("input[type=submit]")
      .toggleAttribute("disabled", !confirmation)
  }
}
